//
//  LawyersNetworkRouter.swift
//  Guard
//
//  Created by Alexandr Bukharin on 08.12.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Alamofire
import Foundation

struct LawyersNetworkRouter {
	private let environment: Environment

	init(environment: Environment) {
		self.environment = environment
	}

	func getAllLawyers(from city: String) -> URLRequestConvertible {
		do {
			return try AllLawyers(environment: environment,
								  city: city).asURLDefaultRequest()
		} catch {
			return AllLawyers(environment: environment,
							  city: city)
		}
	}
}

extension LawyersNetworkRouter {

	private struct AllLawyers: RequestRouter {

		let environment: Environment

		let city: String

		init(environment: Environment,
			 city: String) {
			self.environment = environment
			self.city = city
		}

		var baseUrl: URL {
			return environment.baseUrl
		}

		var method: HTTPMethod = .get
		var path = ApiMethods.getAllLawyers
		var parameters: Parameters {
			return [
				"cityTitle" : city
			]
		}
	}
}
