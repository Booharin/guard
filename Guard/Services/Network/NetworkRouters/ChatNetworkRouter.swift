//
//  ChatNetworkRouter.swift
//  Guard
//
//  Created by Alexandr Bukharin on 13.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import Alamofire
import Foundation

struct ChatNetworkRouter {
	private let environment: Environment

	init(environment: Environment) {
		self.environment = environment
	}

	func getConversations(profileId: Int,
						  isLawyer: Bool,
						  page: Int,
						  pageSize: Int,
						  token: String?) -> URLRequestConvertible {
		do {
			return try AllConversations(environment: environment,
										profileId: profileId,
										isLawyer: isLawyer,
										page: page,
										pageSize: pageSize).asURLDefaultRequest(with: token)
		} catch {
			return AllConversations(environment: environment,
									profileId: profileId,
									isLawyer: isLawyer,
									page: page,
									pageSize: pageSize)
		}
	}

	func getMessages(conversationId: Int, token: String?) -> URLRequestConvertible {
		do {
			return try AllMessages(environment: environment,
								   conversationId: conversationId).asURLDefaultRequest(with: token)
		} catch {
			return AllMessages(environment: environment,
							   conversationId: conversationId)
		}
	}

	func createConversation(lawyerId: Int,
							clientId: Int,
							token: String?) -> URLRequestConvertible {
		do {
			return try CreateChat(environment: environment,
								  lawyerId: lawyerId,
								  clientId: clientId).asURLDefaultRequest(with: token)
		} catch {
			return CreateChat(environment: environment,
							  lawyerId: lawyerId,
								 clientId: clientId)
		}
	}

	func createConversationByAppeal(lawyerId: Int,
									clientId: Int,
									appealId: Int,
									token: String?) -> URLRequestConvertible {
		do {
			return try CreateChatByAppeal(environment: environment,
										  lawyerId: lawyerId,
										  clientId: clientId,
										  appealId: appealId).asURLDefaultRequest(with: token)
		} catch {
			return CreateChatByAppeal(environment: environment,
									  lawyerId: lawyerId,
									  clientId: clientId,
									  appealId: appealId)
		}
	}

	func deleteConversation(conversationId: Int, token: String?) -> URLRequestConvertible {
		do {
			return try DeleteChat(environment: environment,
								  conversationId: conversationId).asURLDefaultRequest(with: token)
		} catch {
			return DeleteChat(environment: environment,
							  conversationId: conversationId)
		}
	}

	func setMessagesRead(conversationId: Int,
						 token: String?) -> URLRequestConvertible {
		do {
			return try MessagesSetRead(environment: environment,
									   conversationId: conversationId).asURLDefaultRequest(with: token)
		} catch {
			return MessagesSetRead(environment: environment,
								   conversationId: conversationId)
		}
	}
}

extension ChatNetworkRouter {

	private struct AllConversations: RequestRouter {

		let environment: Environment
		let profileId: Int
		let isLawyer: Bool
		let page: Int
		let pageSize: Int

		init(environment: Environment,
			 profileId: Int,
			 isLawyer: Bool,
			 page: Int,
			 pageSize: Int) {
			self.environment = environment
			self.profileId = profileId
			self.isLawyer = isLawyer
			self.page = page
			self.pageSize = pageSize
		}

		var baseUrl: URL {
			return environment.baseUrl
		}

		var method: HTTPMethod = .get
		var path = ApiMethods.getConversations
		var parameters: Parameters {
			return [
				"id": profileId,
				"isLawyer": isLawyer,
				"page": page,
				"pageSize": pageSize
			]
		}
	}

	private struct AllMessages: RequestRouter {

		let environment: Environment
		let conversationId: Int

		init(environment: Environment,
			 conversationId: Int) {
			self.environment = environment
			self.conversationId = conversationId
		}

		var baseUrl: URL {
			return environment.baseUrl
		}

		var method: HTTPMethod = .get
		var path = ApiMethods.getMessages
		var parameters: Parameters {
			return [
				"chatId": conversationId
			]
		}
	}

	private struct CreateChat: RequestRouter {

		let environment: Environment
		let lawyerId: Int
		let clientId: Int

		init(environment: Environment,
			 lawyerId: Int,
			 clientId: Int) {
			self.environment = environment
			self.lawyerId = lawyerId
			self.clientId = clientId
		}

		var baseUrl: URL {
			return environment.baseUrl
		}

		var method: HTTPMethod = .post
		var path = ApiMethods.createConversation
		var parameters: Parameters {
			return [
				"lawyerId": lawyerId,
				"clientId": clientId
			]
		}
	}

	private struct CreateChatByAppeal: RequestRouter {

		let environment: Environment
		let lawyerId: Int
		let clientId: Int
		let appealId: Int

		init(environment: Environment,
			 lawyerId: Int,
			 clientId: Int,
			 appealId: Int) {
			self.environment = environment
			self.lawyerId = lawyerId
			self.clientId = clientId
			self.appealId = appealId
		}

		var baseUrl: URL {
			return environment.baseUrl
		}

		var method: HTTPMethod = .post
		var path = ApiMethods.createConversationByAppeal
		var parameters: Parameters {
			return [
				"lawyerId": lawyerId,
				"clientId": clientId,
				"appealId": appealId
			]
		}
	}

	private struct DeleteChat: RequestRouter {

		let environment: Environment
		let conversationId: Int

		init(environment: Environment,
			 conversationId: Int) {
			self.environment = environment
			self.conversationId = conversationId
		}

		var baseUrl: URL {
			return environment.baseUrl
		}

		var method: HTTPMethod = .post
		var path = ApiMethods.deleteConversation
		var parameters: Parameters {
			return [
				"conversationId": conversationId
			]
		}
	}

	private struct MessagesSetRead: RequestRouter {

		let environment: Environment
		let conversationId: Int

		init(environment: Environment,
			 conversationId: Int) {
			self.environment = environment
			self.conversationId = conversationId
		}

		var baseUrl: URL {
			return environment.baseUrl
		}

		var method: HTTPMethod = .get
		var path = ApiMethods.messagesSetRead
		var parameters: Parameters {
			return [
				"chatId": conversationId
			]
		}
	}
}
