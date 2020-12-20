//
//  NetworkConnectivity.swift
//  Guard
//
//  Created by Alexandr Bukharin on 20.12.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Alamofire

struct NetworkConnectivity {
	static let sharedInstance = NetworkReachabilityManager()!
	static var isConnectedToInternet: Bool {
		return self.sharedInstance.isReachable
	}
}
