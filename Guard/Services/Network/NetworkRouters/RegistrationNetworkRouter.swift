//
//  RegistrationNetworkRouter.swift
//  Guard
//
//  Created by Alexandr Bukharin on 28.11.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Alamofire
import Foundation

struct RegistrationNetworkRouter {
	private let environment: Environment

	init(environment: Environment) {
		self.environment = environment
	}

	func signUp(email: String,
				password: String,
				city: String,
				role: UserRole) -> URLRequestConvertible {
		do {
			return try SignUp(environment: environment,
							  email: email,
							  password: password,
							  city: city,
							  userRole: role).asJSONURLRequest()
		} catch {
			#if DEBUG
			print("Error JSON URLRequest", error)
			#endif
			return SignUp(environment: environment,
						  email: email,
						  password: password,
						  city: city,
						  userRole: role)
		}
	}
}

extension RegistrationNetworkRouter {

	private struct SignUp: RequestRouter {

		let environment: Environment

		let email: String
		let password: String
		let city: String
		let userRole: UserRole

		init(environment: Environment,
			 email: String,
			 password: String,
			 city: String,
			 userRole: UserRole) {
			self.environment = environment
			self.email = email
			self.password = password
			self.city = city
			self.userRole = userRole
		}

		var baseUrl: URL {
			return environment.baseUrl
		}

		var method: HTTPMethod = .post
		var path = ApiMethods.register
		var parameters: Parameters {
			return [
				"email" : email,
				"password" : password,
				"city": city,
				"role": userRole.rawValue,
				"issueCode": []
			]
		}
	}
}
