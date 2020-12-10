//
//  RequestRouter.swift
//  Guard
//
//  Created by Alexandr Bukharin on 16.11.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Alamofire
import Foundation

public protocol RequestRouter: URLRequestConvertible {
	var baseUrl: URL { get }
	var method: HTTPMethod { get }
	var path: String { get }
	var parameters: Parameters { get }
	var fullUrl: URL { get }
}

public extension RequestRouter {
	var fullUrl: URL {
		return baseUrl.appendingPathComponent(path)
	}

	func asJSONURLRequest() throws -> URLRequest {
		var urlRequest = URLRequest(url: fullUrl)
		urlRequest.httpMethod = method.rawValue
		urlRequest.allHTTPHeaderFields = [
			"Content-Type" : "application/json"
		]

		return try JSONEncoding.default.encode(urlRequest, with: parameters)
	}

	func asURLRequest() throws -> URLRequest {
		var urlRequest = URLRequest(url: fullUrl)
		urlRequest.httpMethod = method.rawValue
		urlRequest.allHTTPHeaderFields = [
			"Content-Type" : "application/x-www-form-urlencoded"
		]

		return try URLEncoding.httpBody.encode(urlRequest, with: parameters)
	}

	//MARK: - Token
	func asURLDefaultRequest(with token: String? = nil) throws -> URLRequest {
		var urlRequest = URLRequest(url: fullUrl)
		urlRequest.httpMethod = method.rawValue
		if let token = token {
			urlRequest.allHTTPHeaderFields = [
				"Authorization" : "Bearer_\(token)"
			]
		}
		return try URLEncoding.default.encode(urlRequest, with: parameters)
	}
}
