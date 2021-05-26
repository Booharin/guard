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

	func getSettings(profileId: Int) -> Observable<Result<SettingsModel, AFError>>
	func saveSettings(settingsModel: SettingsModel) -> Observable<Result<Any, AFError>>

	func reviewUpload(reviewDescription: String,
					  rating: Double,
					  senderId: Int,
					  receiverId: Int) -> Observable<Result<Any, AFError>>
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
					case 401:
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
			let baseUrlString = EnvironmentImp().baseUrl.description
			guard
				let data = imageData,
				let image = UIImage(data: data),
				let jpegData = image.jpegData(compressionQuality: 0.5) else {
				return Disposables.create(with: {
					AF.request(baseUrlString).cancel()
				}) }

			var imgData = Data(jpegData)

			let kbImageSize = Double(imgData.count) / 1000.0
			if kbImageSize >= 1000 {
				guard let jpegData = image.jpegData(compressionQuality: 0.25) else {
					return Disposables.create(with: {
						AF.request(baseUrlString).cancel()
					})}
				imgData = Data(jpegData)
			}

			let headers: HTTPHeaders = [
				"Content-Type": "multipart/form-data",
				"Authorization": "Bearer_\(self.di.keyChainService.getValue(for: Constants.KeyChainKeys.token)!)"
			]

			let urlString = "\(baseUrlString)users/\(profileId)/image/upload"
			guard let url = URL(string: urlString) else {
				return Disposables.create(with: {
					AF.request(baseUrlString).cancel()
				})
			}
			let requestReference =
				AF.upload(multipartFormData:{ multipartFormData in
							multipartFormData.append(imgData,
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
						self.di.localStorageService.saveImage(data: imgData,
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

//				// handle http status
//				if let code = response.response?.statusCode {
//					switch code {
//					case 401:
//						NotificationCenter.default.post(name: Notification.Name(Constants.NotificationKeys.logout),
//														object: nil)
//					default:
//						break
//					}
//				}

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

	func getSettings(profileId: Int) -> Observable<Result<SettingsModel, AFError>> {
		return Observable<Result>.create { (observer) -> Disposable in
			let requestReference = AF.request(
				self.router.getSettings(id: profileId,
										token: self.di.keyChainService.getValue(for: Constants.KeyChainKeys.token))
			)
			.responseJSON { response in
				#if DEBUG
				print(response)
				#endif

				// handle http status
				if let code = response.response?.statusCode {
					switch code {
					case 401:
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
					do {
						let settings = try JSONDecoder().decode(SettingsModel.self, from: data)
						observer.onNext(.success(settings))
					} catch {
						#if DEBUG
						print(error)
						#endif
						observer.onNext(.failure(AFError.createURLRequestFailed(error: NetworkError.common)))
					}
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

	func saveSettings(settingsModel: SettingsModel) -> Observable<Result<Any, AFError>> {
		return Observable<Result>.create { (observer) -> Disposable in
			let requestReference = AF.request(
				self.router.saveSettings(settingsModel: settingsModel,
										 token: self.di.keyChainService.getValue(for: Constants.KeyChainKeys.token))
			)
			.response { response in
				#if DEBUG
				print(response)
				#endif

				// handle http status
				if let code = response.response?.statusCode {
					switch code {
					case 401:
						NotificationCenter.default.post(name: Notification.Name(Constants.NotificationKeys.logout),
														object: nil)
					default:
						break
					}
				}

				switch response.result {
				case .success:
					self.di.localStorageService.saveSettings(settingsModel)
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

	func reviewUpload(reviewDescription: String,
					  rating: Double,
					  senderId: Int,
					  receiverId: Int) -> Observable<Result<Any, AFError>> {
		return Observable<Result>.create { (observer) -> Disposable in
			let requestReference = AF.request(
				self.router.reviewUpload(reviewDescription: reviewDescription,
										 rating: rating,
										 senderId: senderId,
										 receiverId: receiverId,
										 token: self.di.keyChainService.getValue(for: Constants.KeyChainKeys.token))
			)
			.response { response in
				#if DEBUG
				print(response)
				#endif

				// handle http status
				if let code = response.response?.statusCode {
					switch code {
					case 401:
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
}
