//
//  ClientNetworkService.swift
//  Guard
//
//  Created by Alexandr Bukharin on 14.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import Alamofire
import RxSwift
import Foundation
import UIKit

protocol HasClientNetworkService {
	var clientNetworkService: ClientNetworkServiceInterface { get set }
}

protocol ClientNetworkServiceInterface {
	func editClient(profile: UserProfile,
					email: String,
					phone: String) -> Observable<Result<Any, AFError>>
	func editPhoto(imageData: Data?,
				   profileId: Int) -> Observable<Result<Any, AFError>>
	func getPhoto(profileId: Int) -> Observable<Result<Data, AFError>>
}

final class ClientNetworkService: ClientNetworkServiceInterface {
	private let router: ClientNetworkRouter
	typealias Dependencies =
		HasKeyChainService &
		HasLocalStorageService
	lazy var di: Dependencies = DI.dependencies

	init() {
		router = ClientNetworkRouter(environment: EnvironmentImp())
	}

	func editClient(profile: UserProfile,
					email: String,
					phone: String) -> Observable<Result<Any, AFError>> {
		return Observable<Result>.create { (observer) -> Disposable in
			let requestReference = AF.request(
				self.router.editClient(profile: profile,
									   email: email,
									   phone: phone,
									   token: self.di.keyChainService.getValue(for: Constants.KeyChainKeys.token))
			)
			.response { response in
				#if DEBUG
				print(response)
				#endif

				// handle http status
				if let code = response.response?.statusCode {
					switch code {
					case 403:
						NotificationCenter.default.post(name: Notification.Name(Constants.NotificationKeys.logout),
														object: nil)
					default:
						break
					}
				}

				switch response.result {
				case .success:
					observer.onNext(.success(()))
				case .failure:
					#if DEBUG
					print(response.error?.localizedDescription ?? "")
					#endif
					observer.onNext(.failure(AFError.createURLRequestFailed(error: response.error ?? NetworkError.common)))
				}
			}
			return Disposables.create(with: {
				requestReference.cancel()
			})
		}
	}

	func editPhoto(imageData: Data?,
				   profileId: Int) -> Observable<Result<Any, AFError>> {
		return Observable<Result>.create { (observer) -> Disposable in
			let headers: HTTPHeaders = [
				"Content-Type": "multipart/form-data",
				"Authorization": "Bearer_\(self.di.keyChainService.getValue(for: Constants.KeyChainKeys.token)!)"
			]
			let baseUrlString = EnvironmentImp().baseUrl.description
			let urlString = "\(baseUrlString)users/\(profileId)/image/upload"
			guard
				let imageData = imageData,
				let url = URL(string: urlString) else {
				return Disposables.create(with: {
					AF.request(baseUrlString).cancel()
				})
			}
			let requestReference =
				AF.upload(multipartFormData:{ multipartFormData in
							multipartFormData.append(imageData,
													 withName: "file",
													 fileName: "\(profileId)_profile_image.jpeg",
													 mimeType: "image/jpeg")},
						  to: url,
						  usingThreshold: UInt64.init(),
						  method: .post,
						  headers: headers)
				.response { response in
					#if DEBUG
					print(response)
					#endif
					if response.data == nil {
						self.di.localStorageService.saveImage(data: imageData,
															  name: "\(profileId)_profile_image.jpeg")
						observer.onNext(.success(()))
					} else {
						observer.onNext(.failure(AFError.createURLRequestFailed(error: NetworkError.common)))
					}
				}
			return Disposables.create(with: {
				requestReference.cancel()
			})
		}
	}

	func getPhoto(profileId: Int) -> Observable<Result<Data, AFError>> {
		return Observable<Result>.create { (observer) -> Disposable in
			let requestReference = AF.request(
				self.router.getPhoto(profileId: profileId,
									   token: self.di.keyChainService.getValue(for: Constants.KeyChainKeys.token))
			)
			.response { response in
				#if DEBUG
				print(response)
				#endif

				// handle http status
				if let code = response.response?.statusCode {
					switch code {
					case 403:
						NotificationCenter.default.post(name: Notification.Name(Constants.NotificationKeys.logout),
														object: nil)
					default:
						break
					}
				}

				switch response.result {
				case .success:
					guard let data = response.data else {
						observer.onNext(.failure(AFError.createURLRequestFailed(error: NetworkError.common)))
						return
					}
					observer.onNext(.success(data))
				case .failure:
					#if DEBUG
					print(response.error?.localizedDescription ?? "")
					#endif
					observer.onNext(.failure(AFError.createURLRequestFailed(error: response.error ?? NetworkError.common)))
				}
			}
			return Disposables.create(with: {
				requestReference.cancel()
			})
		}
	}
}
