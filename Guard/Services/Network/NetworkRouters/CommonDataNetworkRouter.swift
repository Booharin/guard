//
//  CommonDataNetworkRouter.swift
//  Guard
//
//  Created by Alexandr Bukharin on 13.12.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Alamofire
import Foundation

struct CommonDataNetworkRouter {
	private let environment: Environment

	init(environment: Environment) {
		self.environment = environment
	}

	func getCountriesAndCities() -> URLRequestConvertible {
		do {
			return try CountriesAndCities(environment: environment).asURLDefaultRequest()
		} catch {
			return CountriesAndCities(environment: environment)
		}
	}

	func getIssueTypes(for locale: String) -> URLRequestConvertible {
		do {
			return try IssueTypes(environment: environment,
								  locale: locale).asURLDefaultRequest()
		} catch {
			return IssueTypes(environment: environment,
							  locale: locale)
		}
	}
}

extension CommonDataNetworkRouter {

	private struct CountriesAndCities: RequestRouter {

		let environment: Environment

		init(environment: Environment) {
			self.environment = environment
		}

		var baseUrl: URL {
			return environment.baseUrl
		}

		var method: HTTPMethod = .get
		var path = ApiMethods.countriesAndCities
		var parameters: Parameters {
			return [:]
		}
	}

	private struct IssueTypes: RequestRouter {

		let environment: Environment
		let locale: String

		init(environment: Environment,
			 locale: String) {
			self.environment = environment
			self.locale = locale
		}

		var baseUrl: URL {
			return environment.baseUrl
		}

		var method: HTTPMethod = .get
		var path = ApiMethods.issueTypes
		var parameters: Parameters {
			return [
				"locale": locale
			]
		}
	}
}
