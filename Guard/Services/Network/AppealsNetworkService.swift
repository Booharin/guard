//
//  AppealsNetworkService.swift
//  Guard
//
//  Created by Alexandr Bukharin on 09.12.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Alamofire
import RxSwift
import Foundation

protocol HasAppealsNetworkService {
	var appealsNetworkService: AppealsNetworkServiceInterface { get set }
}

protocol AppealsNetworkServiceInterface {
	func getClientAppeals(by id: Int,
						  page: Int,
						  pageSize: Int) -> Observable<Result<[ClientAppeal], AFError>>
	func createAppeal(title: String,
					  appealDescription: String,
					  clientId: Int,
					  subIssueCode: Int,
					  cityCode: Int) -> Observable<Result<Any, AFError>>
	func editAppeal(title: String,
					appealDescription: String,
					appeal: ClientAppeal,
					cityCode: Int) -> Observable<Result<Any, AFError>>
	func deleteAppeal(id: Int) -> Observable<Result<Int?, AFError>>
	func getAppeals(by issueCode: [Int]?,
					city: String,
					page: Int,
					pageSize: Int) -> Observable<Result<[ClientAppeal], AFError>>
	func getClient(by appealId: Int) -> Observable<Result<UserProfile, AFError>>

	func getAppeal(by appealId: Int) -> Observable<Result<ClientAppeal, AFError>>

	func changeAppealStatus(with appealId: Int,
							status: Bool) -> Observable<Result<Any, AFError>>
}

final class AppealsNetworkService: AppealsNetworkServiceInterface, HasDependencies {
	private let router: AppealsNetworkRouter
	typealias Dependencies =
		HasKeyChainService
	lazy var di: Dependencies = DI.dependencies

	init() {
		router = AppealsNetworkRouter(environment: EnvironmentImp())
	}

	func getClientAppeals(by id: Int,
						  page: Int,
						  pageSize: Int) -> Observable<Result<[ClientAppeal], AFError>> {
		return Observable<Result>.create { (observer) -> Disposable in
			let requestReference = AF.request(
				self.router.getClientAppeals(by: id,
											 page: page,
											 pageSize: pageSize,
											 token: self.di.keyChainService.getValue(for: Constants.KeyChainKeys.token))
			)
			.responseJSON { response in
				#if DEBUG
				//print(response)
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
						let appeals = try JSONDecoder().decode([ClientAppeal].self, from: data)
						observer.onNext(.success(appeals))
						observer.onCompleted()
					} catch {
						#if DEBUG
						print(error)
						#endif
						observer.onNext(.failure(AFError.createURLRequestFailed(error: NetworkError.common)))
					}
				case .failure:
					observer.onNext(.failure(AFError.createURLRequestFailed(error: response.error ?? NetworkError.common)))
				}
			}
			return Disposables.create(with: {
				requestReference.cancel()
			})
		}
	}

	func createAppeal(title: String,
					  appealDescription: String,
					  clientId: Int,
					  subIssueCode: Int,
					  cityCode: Int) -> Observable<Result<Any, AFError>> {
		return Observable<Result>.create { (observer) -> Disposable in
			let requestReference = AF.request(
				self.router.createAppeal(title: title,
										 appealDescription: appealDescription,
										 clientId: clientId,
										 subIssueCode: subIssueCode,
										 cityCode: cityCode,
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

	func editAppeal(title: String,
					appealDescription: String,
					appeal: ClientAppeal,
					cityCode: Int) -> Observable<Result<Any, AFError>> {
		return Observable<Result>.create { (observer) -> Disposable in
			let requestReference = AF.request(
				self.router.editAppeal(title: title,
									   appealDescription: appealDescription,
									   appeal: appeal,
									   cityCode: cityCode,
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

	func deleteAppeal(id: Int) -> Observable<Result<Int?, AFError>> {
		return Observable<Result>.create { (observer) -> Disposable in
			let requestReference = AF.request(
				self.router.deleteAppeal(id: id,
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
					observer.onNext(.success(id))
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

	func getAppeals(by issueCode: [Int]? = nil,
					city: String,
					page: Int,
					pageSize: Int) -> Observable<Result<[ClientAppeal], AFError>> {
		return Observable<Result>.create { (observer) -> Disposable in
			let requestReference = AF.request(
				self.router.getAppeals(by: issueCode,
									   cityTitle: city,
									   page: page,
									   pageSize: pageSize,
									   token: self.di.keyChainService.getValue(for: Constants.KeyChainKeys.token))
			)
			.responseJSON { response in
//				#if DEBUG
//				print(response)
//				#endif

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
						let appeals = try JSONDecoder().decode([ClientAppeal].self, from: data)
						observer.onNext(.success(appeals))
						observer.onCompleted()
					} catch {
						#if DEBUG
						print(error)
						#endif
						observer.onNext(.failure(AFError.createURLRequestFailed(error: NetworkError.common)))
					}
				case .failure:
					observer.onNext(.failure(AFError.createURLRequestFailed(error: response.error ?? NetworkError.common)))
				}
			}
			return Disposables.create(with: {
				requestReference.cancel()
			})
		}
	}

	func getClient(by appealId: Int) -> Observable<Result<UserProfile, AFError>> {
		return Observable<Result>.create { (observer) -> Disposable in
			let requestReference = AF.request(
				self.router.getClient(by: appealId,
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
						let profile = try JSONDecoder().decode(UserProfile.self, from: data)
						observer.onNext(.success(profile))
						observer.onCompleted()
					} catch {
						#if DEBUG
						print(error)
						#endif
						observer.onNext(.failure(AFError.createURLRequestFailed(error: NetworkError.common)))
					}
				case .failure:
					observer.onNext(.failure(AFError.createURLRequestFailed(error: response.error ?? NetworkError.common)))
				}
			}
			return Disposables.create(with: {
				requestReference.cancel()
			})
		}
	}

	func getAppeal(by appealId: Int) -> Observable<Result<ClientAppeal, AFError>> {
		return Observable<Result>.create { (observer) -> Disposable in
			let requestReference = AF.request(
				self.router.getAppeal(by: appealId,
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
						let appeal = try JSONDecoder().decode(ClientAppeal.self, from: data)
						observer.onNext(.success(appeal))
						observer.onCompleted()
					} catch {
						#if DEBUG
						print(error)
						#endif
						observer.onNext(.failure(AFError.createURLRequestFailed(error: NetworkError.common)))
					}
				case .failure:
					observer.onNext(.failure(AFError.createURLRequestFailed(error: response.error ?? NetworkError.common)))
				}
			}
			return Disposables.create(with: {
				requestReference.cancel()
			})
		}
	}

	func changeAppealStatus(with appealId: Int,
							status: Bool) -> Observable<Result<Any, AFError>> {
		return Observable<Result>.create { (observer) -> Disposable in
			let requestReference = AF.request(
				self.router.changeAppealStatus(id: appealId,
											   status: status,
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
