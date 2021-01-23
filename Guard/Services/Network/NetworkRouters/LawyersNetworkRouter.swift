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

	func getLawyers(by issueCode: [Int],
					cityTitle: String,
					token: String?) -> URLRequestConvertible {
		do {
			if issueCode.isEmpty {
				return try AllLawyers(environment: environment,
									  city: cityTitle).asURLDefaultRequest(with: token)
			} else {
				return try LawyersByIssue(environment: environment,
										  issueCode: issueCode,
										  cityTitle: cityTitle).asURLDefaultRequest(with: token)
			}
		} catch {
			return LawyersByIssue(environment: environment,
								  issueCode: issueCode,
								  cityTitle: cityTitle)
		}
	}

	func editLawyer(profile: UserProfile,
					email: String,
					phone: String,
					token: String?) -> URLRequestConvertible {
		do {
			return try EditLawyer(environment: environment,
								  lawyerProfile: profile,
								  email: email,
								  phone: phone).asJSONURLRequest(with: token)
		} catch {
			#if DEBUG
			print("Error JSON URLRequest", error)
			#endif
			return EditLawyer(environment: environment,
							  lawyerProfile: profile,
							  email: email,
							  phone: phone)
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

	private struct LawyersByIssue: RequestRouter {

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
		var path = ApiMethods.getLawyers
		var parameters: Parameters {
			return [
				"issueCode": issueCode
					.map { String($0) }
					.joined(separator:","),
				"cityTitle": cityTitle
			]
		}
	}

	private struct EditLawyer: RequestRouter {

		let environment: Environment

		let id: Int
		let firstName: String
		let lastName: String
		let email: String
		let phoneNumber: String
		var photo: String?
		let cityCode: [Int]
		let countryCode: [Int]
		let issueCodes: [Int]

		init(environment: Environment,
			 lawyerProfile: UserProfile,
			 email: String,
			 phone: String) {

			self.environment = environment
			self.id = lawyerProfile.id
			self.firstName = lawyerProfile.firstName ?? ""
			self.lastName = lawyerProfile.lastName ?? ""
			self.email = email
			self.phoneNumber = phone
			self.photo = lawyerProfile.photo
			self.cityCode = lawyerProfile.cityCode ?? []
			self.countryCode = lawyerProfile.countryCode ?? []
			self.issueCodes = lawyerProfile.issueCodes ?? []
		}

		var baseUrl: URL {
			return environment.baseUrl
		}

		var method: HTTPMethod = .post
		var path = ApiMethods.editLawyer
		var parameters: Parameters {
			return [
				"id": id,
				"firstName": firstName,
				"lastName": lastName,
				"email": email,
				"phoneNumber": phoneNumber,
				"photo": photo,
				"cityCode": cityCode,
				"countryCode": countryCode,
				"issueCodes": issueCodes
			]
		}
	}
}
