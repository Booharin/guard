//
//  AuthService.swift
//  Guard
//
//  Created by Alexandr Bukharin on 16.11.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Alamofire
import RxSwift
import KeychainSwift

protocol HasAuthService {
	var authService: AuthServiceInterface { get set }
}

protocol AuthServiceInterface {
	func signIn(email: String, password: String) -> Observable<Result<UserRole, AFError>>
	func forgotPassword(email: String) -> Observable<Result<Any, AFError>>
	func changePassword(id: Int,
						oldPassword: String,
						newPassword: String) -> Observable<Result<Any, AFError>>
}

final class AuthService: AuthServiceInterface, HasDependencies {

	private let router: AuthNetworkRouter
	typealias Dependencies =
		HasKeyChainService &
		HasLocalStorageService &
		HasAlertService
	lazy var di: Dependencies = DI.dependencies

	init() {
		router = AuthNetworkRouter(environment: EnvironmentImp())
	}

	func signIn(email: String, password: String) -> Observable<Result<UserRole, AFError>> {
		return Observable<Result>.create { (observer) -> Disposable in
			let requestReference = AF.request(self.router.signIn(email: email, password: password))
				.responseJSON { response in
					#if DEBUG
					print(response)
					#endif
					// handle http status
					if let code = response.response?.statusCode {
						switch code {
						case 403:
							self.di.alertService.showAlert(title: "alert.warning.title".localized,
														   message: "alert.login.message".localized,
														   okButtonTitle: "alert.ok".localized.capitalized,
														   completion: { _ in })
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
							let authResponce = try JSONDecoder().decode(AuthResponse.self, from: data)
							guard
								let token = authResponce.token,
								var user = authResponce.user else {
								observer.onNext(.failure(AFError.createURLRequestFailed(error: NetworkError.common)))
									return
							}
							self.di.keyChainService.save(token, for: Constants.KeyChainKeys.token)
							self.di.keyChainService.save(email, for: Constants.KeyChainKeys.email)
							self.di.keyChainService.save(password, for: Constants.KeyChainKeys.password)
							self.di.keyChainService.save(user.phoneNumber ?? "", for: Constants.KeyChainKeys.phoneNumber)

							// MARK: - Save issue codes
							user.issueCodes = user.issueTypes?.map { $0.issueCode }

							self.di.localStorageService.saveProfile(user)
							if let reviews = user.reviewList {
								self.di.localStorageService.saveReviews(reviews)
							}
							UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKeys.isLogin)

							observer.onNext(.success(user.userRole))
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

	func forgotPassword(email: String) -> Observable<Result<Any, AFError>> {
		return Observable<Result>.create { (observer) -> Disposable in
			let requestReference = AF.request(self.router.forgotPassword(email: email))
				.response { response in
					#if DEBUG
					print(response)
					#endif
					switch response.result {
					case .success:
						observer.onNext(.success(()))
					case .failure:
						observer.onNext(.failure(AFError.createURLRequestFailed(error: response.error ?? NetworkError.common)))
					}
				}
			return Disposables.create(with: {
				requestReference.cancel()
			})
		}
	}

	func changePassword(id: Int,
						oldPassword: String,
						newPassword: String) -> Observable<Result<Any, AFError>> {
		return Observable<Result>.create { (observer) -> Disposable in
			let requestReference = AF.request(self.router.changePassword(id: id,
																		 oldPassword: oldPassword,
																		 newPassword: newPassword))
				.response { response in
					#if DEBUG
					print(response)
					#endif
					switch response.result {
					case .success:
						observer.onNext(.success(()))
					case .failure:
						observer.onNext(.failure(AFError.createURLRequestFailed(error: response.error ?? NetworkError.common)))
					}
				}
			return Disposables.create(with: {
				requestReference.cancel()
			})
		}
	}
}
