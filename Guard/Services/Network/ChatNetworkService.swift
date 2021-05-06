//
//  ChatNetworkService.swift
//  Guard
//
//  Created by Alexandr Bukharin on 13.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import Alamofire
import RxSwift
import Foundation

protocol HasChatNetworkService {
	var chatNetworkService: ChatNetworkServiceInterface { get set }
}

protocol ChatNetworkServiceInterface {
	func createConversation(lawyerId: Int,
							clientId: Int) -> Observable<Result<Any, AFError>>
	func createConversationByAppeal(lawyerId: Int,
									clientId: Int,
									appealId: Int) -> Observable<Result<Any, AFError>>
	func deleteConversation(conversationId: Int) -> Observable<Result<Int?, AFError>>
	func getConversations(with profileId: Int,
						  isLawyer: Bool) -> Observable<Result<[ChatConversation], AFError>>
	func getMessages(with conversationId: Int) -> Observable<Result<[ChatMessage], AFError>>
	func setMessagesRead(conversationId: Int) -> Observable<Result<Any, AFError>>
}

final class ChatNetworkService: ChatNetworkServiceInterface, HasDependencies {
	private let router: ChatNetworkRouter
	typealias Dependencies =
		HasKeyChainService
	lazy var di: Dependencies = DI.dependencies

	init() {
		router = ChatNetworkRouter(environment: EnvironmentImp())
	}

	func createConversation(lawyerId: Int, clientId: Int) -> Observable<Result<Any, AFError>> {
		return Observable<Result>.create { (observer) -> Disposable in
			let requestReference = AF.request(
				self.router.createConversation(lawyerId: lawyerId,
											   clientId: clientId,
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
					observer.onNext(.failure(AFError.createURLRequestFailed(error: response.error ?? NetworkError.common)))
				}
			}
			return Disposables.create(with: {
				requestReference.cancel()
			})
		}
	}

	func createConversationByAppeal(lawyerId: Int,
									clientId: Int,
									appealId: Int) -> Observable<Result<Any, AFError>> {
		return Observable<Result>.create { (observer) -> Disposable in
			let requestReference = AF.request(
				self.router.createConversationByAppeal(lawyerId: lawyerId,
													   clientId: clientId,
													   appealId: appealId,
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
					observer.onNext(.failure(AFError.createURLRequestFailed(error: response.error ?? NetworkError.common)))
				}
			}
			return Disposables.create(with: {
				requestReference.cancel()
			})
		}
	}

	func deleteConversation(conversationId: Int) -> Observable<Result<Int?, AFError>> {
		return Observable<Result>.create { (observer) -> Disposable in
			let requestReference = AF.request(
				self.router.deleteConversation(conversationId: conversationId,
										token: self.di.keyChainService.getValue(for: Constants.KeyChainKeys.token))
			)
			.response { response in
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
					observer.onNext(.success(conversationId))
				case .failure:
					observer.onNext(.failure(AFError.createURLRequestFailed(error: response.error ?? NetworkError.common)))
				}
			}
			return Disposables.create(with: {
				requestReference.cancel()
			})
		}
	}

	func getConversations(with profileId: Int,
						  isLawyer: Bool) -> Observable<Result<[ChatConversation], AFError>> {
		return Observable<Result>.create { (observer) -> Disposable in
			let requestReference = AF.request(
				self.router.getConversations(profileId: profileId,
											 isLawyer: isLawyer,
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
						let conversations = try JSONDecoder().decode([ChatConversation].self, from: data)
						observer.onNext(.success(conversations))
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

	func getMessages(with conversationId: Int) -> Observable<Result<[ChatMessage], AFError>> {
		return Observable<Result>.create { (observer) -> Disposable in
			let requestReference = AF.request(
				self.router.getMessages(conversationId: conversationId,
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
						let messages = try JSONDecoder().decode([ChatMessage].self, from: data)
						observer.onNext(.success(messages))
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

	func setMessagesRead(conversationId: Int) -> Observable<Result<Any, AFError>> {
		return Observable<Result>.create { (observer) -> Disposable in
			let requestReference = AF.request(
				self.router.setMessagesRead(conversationId: conversationId,
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
					observer.onNext(.failure(AFError.createURLRequestFailed(error: response.error ?? NetworkError.common)))
				}
			}
			return Disposables.create(with: {
				requestReference.cancel()
			})
		}
	}
}
