//
//  RegistrationService.swift
//  Guard
//
//  Created by Alexandr Bukharin on 28.11.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Alamofire
import RxSwift
import KeychainSwift

protocol HasRegistrationService {
	var registrationService: RegistrationServiceInterface { get set }
}

protocol RegistrationServiceInterface {
	func signUp(email: String,
				password: String,
				city: String,
				userRole: UserRole) -> Observable<Result<Any, AFError>>
}

final class RegistrationService: RegistrationServiceInterface, HasDependencies {

	private let router: RegistrationNetworkRouter
	typealias Dependencies =
		HasKeyChainService &
		HasLocalStorageService
	lazy var di: Dependencies = DI.dependencies

	init() {
		router = RegistrationNetworkRouter(environment: EnvironmentImp())
	}

	func signUp(email: String,
				password: String,
				city: String,
				userRole: UserRole) -> Observable<Result<Any, AFError>> {
		return Observable<Result>.create { (observer) -> Disposable in
			let requestReference = AF.request(self.router.signUp(email: email,
																 password: password,
																 city: city,
																 role: userRole))
				.responseJSON { response in
					#if DEBUG
					print(response)
					#endif
					switch response.result {
					case .success:
						self.di.keyChainService.save(email, for: Constants.KeyChainKeys.email)
						self.di.keyChainService.save(password, for: Constants.KeyChainKeys.password)
						observer.onNext(.success(()))
//						guard let data = response.data else {
//							observer.onNext(.failure(AFError.createURLRequestFailed(error: NetworkError.common)))
//							return
//						}
//						do {
//							let authResponce = try JSONDecoder().decode(AuthResponse.self, from: data)
//							guard
//								let token = authResponce.token,
//								let user = authResponce.user else {
//								observer.onNext(.failure(AFError.createURLRequestFailed(error: NetworkError.common)))
//									return
//							}
//							#if DEBUG
//							print(token)
//							#endif
//
//							self.di.keyChainService.save(token, for: Constants.KeyChainKeys.token)
//							self.di.keyChainService.save(email, for: Constants.KeyChainKeys.email)
//							self.di.keyChainService.save(password, for: Constants.KeyChainKeys.password)
//							self.di.keyChainService.save(user.phoneNumber ?? "", for: Constants.KeyChainKeys.phoneNumber)
//							self.di.localStorageService.saveProfile(user)
//
//							observer.onNext(.success(user.userRole))
//							observer.onCompleted()
//						} catch {
//							#if DEBUG
//							print(error)
//							#endif
//							observer.onNext(.failure(AFError.createURLRequestFailed(error: NetworkError.common)))
//						}
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
