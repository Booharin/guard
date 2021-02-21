//
//  ClientNetworkRouter.swift
//  Guard
//
//  Created by Alexandr Bukharin on 14.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import Alamofire
import Foundation

struct ClientNetworkRouter {
	private let environment: Environment

	init(environment: Environment) {
		self.environment = environment
	}

	func editClient(profile: UserProfile,
					email: String,
					phone: String,
					token: String?) -> URLRequestConvertible {
		do {
			return try EditClient(environment: environment,
								  clientProfile: profile,
								  email: email,
								  phone: phone).asJSONURLRequest(with: token)
		} catch {
			#if DEBUG
			print("Error JSON URLRequest", error)
			#endif
			return EditClient(environment: environment,
							  clientProfile: profile,
								 email: email,
								 phone: phone)
		}
	}

	func getPhoto(profileId: Int,
				  token: String?) -> URLRequestConvertible {
		do {
			return try GetPhoto(environment: environment,
								id: profileId).asURLDefaultRequest(with: token)
		} catch {
			#if DEBUG
			print("Error JSON URLRequest", error)
			#endif
			return GetPhoto(environment: environment,
							id: profileId)
		}
	}

	func getSettings(id: Int,
					 token: String?) -> URLRequestConvertible {
		do {
			return try GetSettings(environment: environment,
								   id: id).asURLDefaultRequest(with: token)
		} catch {
			#if DEBUG
			print("Error JSON URLRequest", error)
			#endif
			return GetSettings(environment: environment,
							   id: id)
		}
	}

	func saveSettings(settingsModel: SettingsModel,
					  token: String?) -> URLRequestConvertible {
		do {
			return try SaveSettings(environment: environment,
									settingsModel: settingsModel).asJSONURLRequest(with: token)
		} catch {
			#if DEBUG
			print("Error JSON URLRequest", error)
			#endif
			return SaveSettings(environment: environment,
								settingsModel: settingsModel)
		}
	}

	func reviewUpload(reviewDescription: String,
					  rating: Double,
					  senderId: Int,
					  receiverId: Int,
					  token: String?) -> URLRequestConvertible {
		do {
			return try ReviewUpload(environment: environment,
									reviewDescription: reviewDescription,
									rating: rating,
									senderId: senderId,
									receiverId: receiverId).asJSONURLRequest(with: token)
		} catch {
			#if DEBUG
			print("Error JSON URLRequest", error)
			#endif
			return ReviewUpload(environment: environment,
								reviewDescription: reviewDescription,
								rating: rating,
								senderId: senderId,
								receiverId: receiverId)
		}
	}
}

extension ClientNetworkRouter {

	private struct EditClient: RequestRouter {

		let environment: Environment

		let id: Int
		let firstName: String
		let lastName: String
		let email: String
		let phoneNumber: String
		var photo: String?
		let cityCode: [Int]
		let countryCode: [Int]

		init(environment: Environment,
			 clientProfile: UserProfile,
			 email: String,
			 phone: String) {

			self.environment = environment
			self.id = clientProfile.id
			self.firstName = clientProfile.firstName ?? ""
			self.lastName = clientProfile.lastName ?? ""
			self.email = email
			self.phoneNumber = phone
			self.photo = clientProfile.photo
			self.cityCode = clientProfile.cityCode ?? []
			self.countryCode = clientProfile.countryCode ?? []
		}

		var baseUrl: URL {
			return environment.baseUrl
		}

		var method: HTTPMethod = .post
		var path = ApiMethods.editClient
		var parameters: Parameters {
			return [
				"id": id,
				"firstName": firstName,
				"lastName": lastName,
				"email": email,
				"phoneNumber": phoneNumber,
				"photo": photo,
				"cityCode": cityCode,
				"countryCode": countryCode
			]
		}
	}

	private struct GetPhoto: RequestRouter {

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
		var path: String {
			"users/\(id)/image/download"
		}
		var parameters: Parameters {
			return [:]
		}
	}

	private struct GetSettings: RequestRouter {

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
		var path = ApiMethods.settings
		var parameters: Parameters {
			return [
				"id": id
			]
		}
	}

	private struct SaveSettings: RequestRouter {

		let environment: Environment
		let settingsModel: SettingsModel

		init(environment: Environment,
			 settingsModel: SettingsModel) {

			self.environment = environment
			self.settingsModel = settingsModel
		}

		var baseUrl: URL {
			return environment.baseUrl
		}

		var method: HTTPMethod = .post
		var path = ApiMethods.settings
		var parameters: Parameters {
			return [
				"id": settingsModel.id,
				"isPhoneVisible": settingsModel.isPhoneVisible,
				"isEmailVisible": settingsModel.isEmailVisible,
				"isChatEnabled": settingsModel.isChatEnabled
			]
		}
	}

	private struct ReviewUpload: RequestRouter {

		let environment: Environment
		let reviewDescription: String
		let rating: Double
		let senderId: Int
		let receiverId: Int

		init(environment: Environment,
			 reviewDescription: String,
			 rating: Double,
			 senderId: Int,
			 receiverId: Int) {

			self.environment = environment
			self.reviewDescription = reviewDescription
			self.rating = rating
			self.senderId = senderId
			self.receiverId = receiverId
		}

		var baseUrl: URL {
			return environment.baseUrl
		}

		var method: HTTPMethod = .post
		var path = ApiMethods.reviewUpload
		var parameters: Parameters {
			return [
				"reviewDescription": reviewDescription,
				"rating": rating,
				"senderId": senderId,
				"receiverId": receiverId,
				"dateCreated": Date.getCurrentDate()
			]
		}
	}
}
