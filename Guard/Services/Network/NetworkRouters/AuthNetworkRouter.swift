//
//  AuthNetworkRouter.swift
//  Guard
//
//  Created by Alexandr Bukharin on 16.11.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Alamofire
import Foundation

struct AuthNetworkRouter {
	private let environment: Environment
	
	init(environment: Environment) {
		self.environment = environment
	}

	func signIn(email: String,
				password: String) -> URLRequestConvertible {
		do {
			return try SignIn(environment: environment,
							  email: email,
							  password: password).asJSONURLRequest()
		} catch {
			#if DEBUG
			print("Error JSON URLRequest", error)
			#endif
			return SignIn(environment: environment,
						  email: email,
						  password: password)
		}
	}
}

extension AuthNetworkRouter {
	
	private struct SignIn: RequestRouter {
		
		let environment: Environment
		
		let email: String
		let password: String
		
		init(environment: Environment,
			 email: String,
			 password: String) {
			self.environment = environment
			self.email = email
			self.password = password
		}
		
		var baseUrl: URL {
			return environment.baseUrl
		}
		
		var method: HTTPMethod = .post
		var path = ApiMethods.login
		var parameters: Parameters {
			return [
				"userEmail" : email,
				"userPassword" : password
			]
		}
	}
}
