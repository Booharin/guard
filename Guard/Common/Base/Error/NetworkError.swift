//
//  NetworkError.swift
//  Guard
//
//  Created by Alexandr Bukharin on 16.11.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Foundation

enum NetworkError: Swift.Error {
	case common
	case noConnection
	case custom(String)
	
	var localizedDescription: String {
		switch self {
		case .noConnection:
			return "error.noConnection.title".localized
		case .custom(let text):
			return text
		default:
			return "error.common.title".localized
		}
	}
}
