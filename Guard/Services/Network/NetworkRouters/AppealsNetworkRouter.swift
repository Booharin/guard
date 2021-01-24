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

	func editAppeal(title: String,
					appealDescription: String,
					appeal: ClientAppeal,
					cityCode: Int,
					token: String?) -> URLRequestConvertible {
		do {
			return try EditAppeal(environment: environment,
								  id: appeal.id,
								  title: title,
								  appealDescription: appealDescription,
								  date: appeal.dateCreated,
								  clientId: appeal.clientId,
								  issueCode: appeal.issueCode,
								  cityCode: cityCode).asJSONURLRequest(with: token)
		} catch {
			return EditAppeal(environment: environment,
							  id: appeal.id,
							  title: title,
							  appealDescription: appealDescription,
							  date: appeal.dateCreated,
							  clientId: appeal.clientId,
							  issueCode: appeal.issueCode,
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

	func getAppeals(by city: String, token: String?) -> URLRequestConvertible {
		do {
			return try AllAppeals(environment: environment,
								  cityTitle: city).asURLDefaultRequest(with: token)
		} catch {
			return AllAppeals(environment: environment,
							  cityTitle: city)
		}
	}

	func getAppeals(by issueCode: [Int],
					cityTitle: String,
					token: String?) -> URLRequestConvertible {
		do {
			if issueCode.isEmpty {
				return try AllAppeals(environment: environment,
									  cityTitle: cityTitle).asURLDefaultRequest(with: token)
			} else {
				return try AppealsByIssue(environment: environment,
										  issueCode: issueCode,
										  cityTitle: cityTitle).asURLDefaultRequest(with: token)
			}
		} catch {
			return AppealsByIssue(environment: environment,
								  issueCode: issueCode,
								  cityTitle: cityTitle)
		}
	}

	func getClient(by appealId: Int,
				   token: String?) -> URLRequestConvertible {
		do {
			return try ClientByAppealId(environment: environment,
										appealId: appealId).asURLDefaultRequest(with: token)
		} catch {
			return ClientByAppealId(environment: environment,
									appealId: appealId)
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

	private struct EditAppeal: RequestRouter {

		let environment: Environment
		let id: Int
		let title: String
		let appealDescription: String
		let date: String
		let clientId: Int
		let issueCode: Int
		let cityCode: Int

		init(environment: Environment,
			 id: Int,
			 title: String,
			 appealDescription: String,
			 date: String,
			 clientId: Int,
			 issueCode: Int,
			 cityCode: Int) {
			self.environment = environment
			self.id = id
			self.title = title
			self.appealDescription = appealDescription
			self.date = date
			self.clientId = clientId
			self.issueCode = issueCode
			self.cityCode = cityCode
		}

		var baseUrl: URL {
			return environment.baseUrl
		}

		var method: HTTPMethod = .post
		var path = ApiMethods.editAppeal
		var parameters: Parameters {
			return [
				"id": id,
				"title": title,
				"appealDescription": appealDescription,
				"dateCreated": date,
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

	private struct AllAppeals: RequestRouter {

		let environment: Environment
		let cityTitle: String

		init(environment: Environment,
			 cityTitle: String) {
			self.environment = environment
			self.cityTitle = cityTitle
		}

		var baseUrl: URL {
			return environment.baseUrl
		}

		var method: HTTPMethod = .get
		var path = ApiMethods.allAppeals
		var parameters: Parameters {
			return [
				"cityTitle": cityTitle
			]
		}
	}

	private struct AppealsByIssue: RequestRouter {

		let environment: Environment
		let issueCode: [Int]
		let cityTitle: String

		init(environment: Environment,
			 issueCode: [Int],
			 cityTitle: String) {
			self.environment = environment
			self.issueCode = issueCode
			self.cityTitle = cityTitle
		}

		var baseUrl: URL {
			return environment.baseUrl
		}

		var method: HTTPMethod = .get
		var path = ApiMethods.appealsByIssue
		var parameters: Parameters {
			return [
				"issueCodeList": issueCode
					.map { String($0) }
					.joined(separator:","),
				"city": cityTitle
			]
		}
	}

	private struct ClientByAppealId: RequestRouter {

		let environment: Environment
		let appealId: Int

		init(environment: Environment,
			 appealId: Int) {
			self.environment = environment
			self.appealId = appealId
		}

		var baseUrl: URL {
			return environment.baseUrl
		}

		var method: HTTPMethod = .get
		var path = ApiMethods.clientByAppealId
		var parameters: Parameters {
			return [
				"appealId": appealId
			]
		}
	}
}
