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

	func getConversations(profileId: Int, isLawyer: Bool, token: String?) -> URLRequestConvertible {
		do {
			return try AllConversations(environment: environment,
										profileId: profileId,
										isLawyer: isLawyer).asURLDefaultRequest(with: token)
		} catch {
			return AllConversations(environment: environment,
									profileId: profileId,
									isLawyer: isLawyer)
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
}

extension ChatNetworkRouter {

	private struct AllConversations: RequestRouter {

		let environment: Environment
		let profileId: Int
		let isLawyer: Bool

		init(environment: Environment,
			 profileId: Int,
			 isLawyer: Bool) {
			self.environment = environment
			self.profileId = profileId
			self.isLawyer = isLawyer
		}

		var baseUrl: URL {
			return environment.baseUrl
		}

		var method: HTTPMethod = .get
		var path = ApiMethods.getConversations
		var parameters: Parameters {
			return [
				"id": profileId,
				"isLawyer": isLawyer
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
}
