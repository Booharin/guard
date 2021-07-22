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
				password: String,
				deviceToken: String) -> URLRequestConvertible {
		do {
			return try SignIn(environment: environment,
							  email: email,
							  password: password,
							  deviceToken: deviceToken).asJSONURLRequest()
		} catch {
			#if DEBUG
			print("Error JSON URLRequest", error)
			#endif
			return SignIn(environment: environment,
						  email: email,
						  password: password,
						  deviceToken: deviceToken)
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

	func signInById(id: String,
					deviceToken: String) -> URLRequestConvertible {
		do {
			return try SignInWithId(environment: environment,
									id: id,
									deviceToken: deviceToken).asJSONURLRequest()
		} catch {
			#if DEBUG
			print("Error JSON URLRequest", error)
			#endif
			return  SignInWithId(environment: environment,
								 id: id,
								 deviceToken: deviceToken)
		}
	}
}

extension AuthNetworkRouter {

	private struct SignIn: RequestRouter {

		let environment: Environment

		let email: String
		let password: String
		let deviceToken: String

		init(environment: Environment,
			 email: String,
			 password: String,
			 deviceToken: String) {
			self.environment = environment
			self.email = email
			self.password = password
			self.deviceToken = deviceToken
		}

		var baseUrl: URL {
			return environment.baseUrl
		}

		var method: HTTPMethod = .post
		var path = ApiMethods.login
		var parameters: Parameters {
			return [
				"userEmail": email,
				"userPassword": password,
				"tokenDevice": deviceToken
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

	private struct SignInWithId: RequestRouter {

		let environment: Environment

		let id: String
		let deviceToken: String

		init(environment: Environment,
			 id: String,
			 deviceToken: String) {
			self.environment = environment
			self.id = id
			self.deviceToken = deviceToken
		}

		var baseUrl: URL {
			return environment.baseUrl
		}

		var method: HTTPMethod = .post
		var path = ApiMethods.loginWithId
		var parameters: Parameters {
			return [
				"userId": id,
				"tokenDevice": deviceToken
			]
		}
	}
}
