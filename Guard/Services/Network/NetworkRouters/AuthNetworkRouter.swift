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

	func forgotPassword(email: String) -> URLRequestConvertible {
		do {
			return try ForgotPassword(environment: environment,
									  email: email).asURLDefaultRequest()
		} catch {
			return ForgotPassword(environment: environment,
								  email: email)
		}
	}

	func changePassword(id: Int,
						oldPassword: String,
						newPassword: String) -> URLRequestConvertible {
		do {
			return try ChangePassword(environment: environment,
									  id: id,
									  oldPassword: oldPassword,
									  newPassword: newPassword).asJSONURLRequest()
		} catch {
			#if DEBUG
			print("Error JSON URLRequest", error)
			#endif
			return ChangePassword(environment: environment,
								  id: id,
								  oldPassword: oldPassword,
								  newPassword: newPassword)
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
				"userEmail": email,
				"userPassword": password
			]
		}
	}

	private struct ForgotPassword: RequestRouter {

		let environment: Environment
		let email: String

		init(environment: Environment,
			 email: String) {
			self.environment = environment
			self.email = email
		}

		var baseUrl: URL {
			return environment.baseUrl
		}

		var method: HTTPMethod = .post
		var path = ApiMethods.forgotPassword
		var parameters: Parameters {
			return [
				"email": email
			]
		}
	}

	private struct ChangePassword: RequestRouter {

		let environment: Environment
		let id: Int
		let oldPassword: String
		let newPassword: String

		init(environment: Environment,
			 id: Int,
			 oldPassword: String,
			 newPassword: String) {
			self.environment = environment
			self.id = id
			self.oldPassword = oldPassword
			self.newPassword = newPassword
		}

		var baseUrl: URL {
			return environment.baseUrl
		}

		var method: HTTPMethod = .post
		var path = ApiMethods.changePassword
		var parameters: Parameters {
			return [
				"id": id,
				"oldPassword": oldPassword,
				"newPassword": newPassword
			]
		}
	}
}
