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

	func getAllLawyers(from city: String, token: String?) -> URLRequestConvertible {
		do {
			return try AllLawyers(environment: environment,
								  city: city).asURLDefaultRequest(with: token)
		} catch {
			return AllLawyers(environment: environment,
							  city: city)
		}
	}

	func getLawyer(by id: Int, token: String?) -> URLRequestConvertible {
		do {
			return try GetLawyer(environment: environment,
								 id: id).asURLDefaultRequest(with: token)
		} catch {
			return GetLawyer(environment: environment,
							 id: id)
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
				"cityTitle": city
			]
		}
	}

	private struct GetLawyer: RequestRouter {

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
		var path = ApiMethods.getLawyer
		var parameters: Parameters {
			return [
				"id": id
			]
		}
	}
}
