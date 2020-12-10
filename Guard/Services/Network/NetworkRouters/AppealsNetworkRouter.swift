//
//  AppealsNetworkRouter.swift
//  Guard
//
//  Created by Alexandr Bukharin on 09.12.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Alamofire
import Foundation

struct AppealsNetworkRouter {
	private let environment: Environment

	init(environment: Environment) {
		self.environment = environment
	}

	func getClientAppeals(by id: Int, token: String?) -> URLRequestConvertible {
		do {
			return try ClientAppeals(environment: environment,
									 id: id).asURLDefaultRequest(with: token)
		} catch {
			return ClientAppeals(environment: environment,
								 id: id)
		}
	}
}

extension AppealsNetworkRouter {

	private struct ClientAppeals: RequestRouter {

		let environment: Environment
		let id: Int

		init(environment: Environment,
			 id: Int) {
			self.environment = environment
			self.id = id
		}

		var baseUrl: URL {
			return environment.baseUrl
		}

		var method: HTTPMethod = .get
		var path = ApiMethods.clientAppeals
		var parameters: Parameters {
			return [
				"id": id
			]
		}
	}
}
