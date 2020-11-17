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
	func signIn(email: String, password: String) -> Observable<Result<Any, AFError>>
}

struct AuthService: AuthServiceInterface {
	
	private let router: AuthNetworkRouter
	
	init() {
		router = AuthNetworkRouter(environment: EnvironmentImp())
	}
	
	func signIn(email: String, password: String) -> Observable<Result<Any, AFError>> {
		return Observable<Result>.create { (observer) -> Disposable in
			let requestReference = AF.request(self.router.signIn(email: email, password: password))
				.responseJSON { response in
					print(response)
					switch response.result {
					case .success:
						guard let data = response.data else {
							observer.onError(NetworkError.common)
							return
						}
						do {
							let authResponce = try JSONDecoder().decode(AuthResponse.self, from: data)
							guard
								let token = authResponce.token,
								let user = authResponce.user else {
									observer.onError(NetworkError.common)
									return
							}
							#if DEBUG
							print(token)
							#endif

							self.saveToken(token: token)
							self.saveUser(user: user)

							observer.onNext(response.result)
							observer.onCompleted()
						} catch {
							#if DEBUG
							print(error)
							#endif
							observer.onError(NetworkError.common)
						}
					case .failure:
						observer.onError(response.error ?? NetworkError.common)
					}
			}
			return Disposables.create(with: {
				requestReference.cancel()
			})
		}
	}
	
	private func saveToken(token: String) {
		let keychain = KeychainSwift()
		keychain.set(token, forKey: Constants.KeyChainKeys.token)
	}
	
//	private func saveUser(user: User) {
//		let realm = try? Realm()
//		let _user = user.toManagedObject()
//		try? realm?.write {
//			realm?.add(_user, update: .all)
//		}
//	}
}
