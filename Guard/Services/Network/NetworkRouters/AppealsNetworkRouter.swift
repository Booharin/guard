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

	func createAppeal(title: String,
					  appealDescription: String,
					  clientId: Int,
					  issueCode: Int,
					  cityCode: Int,
					  token: String?) -> URLRequestConvertible {
		do {
			return try CreateAppeal(environment: environment,
									title: title,
									appealDescription: appealDescription,
									clientId: clientId,
									issueCode: issueCode,
									cityCode: cityCode).asJSONURLRequest(with: token)
		} catch {
			return CreateAppeal(environment: environment,
								title: title,
								appealDescription: appealDescription,
								clientId: clientId,
								issueCode: issueCode,
								cityCode: cityCode)
		}
	}

	func deleteAppeal(id: Int, token: String?) -> URLRequestConvertible {
		do {
			return try DeleteAppeal(environment: environment,
									id: id).asURLDefaultRequest(with: token)
		} catch {
			return DeleteAppeal(environment: environment,
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

	private struct CreateAppeal: RequestRouter {

		let environment: Environment
		let title: String
		let appealDescription: String
		let clientId: Int
		let issueCode: Int
		let cityCode: Int

		init(environment: Environment,
			 title: String,
			 appealDescription: String,
			 clientId: Int,
			 issueCode: Int,
			 cityCode: Int) {
			self.environment = environment
			self.title = title
			self.appealDescription = appealDescription
			self.clientId = clientId
			self.issueCode = issueCode
			self.cityCode = cityCode
		}

		var baseUrl: URL {
			return environment.baseUrl
		}

		var method: HTTPMethod = .post
		var path = ApiMethods.createAppeal
		var parameters: Parameters {
			return [
				"title": title,
				"appealDescription": appealDescription,
				"dateCreated": Date.getCurrentDate(),
				"clientId": clientId,
				"issueCode": issueCode,
				"cityCode": cityCode,
				"isLawyerChoosed": false
			]
		}
	}

	private struct DeleteAppeal: RequestRouter {

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

		var method: HTTPMethod = .post
		var path = ApiMethods.deleteAppeal
		var parameters: Parameters {
			return [
				"appealId": id
			]
		}
	}
}
