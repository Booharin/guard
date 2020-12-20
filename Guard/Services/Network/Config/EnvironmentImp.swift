//
//  EnvironmentImp.swift
//  Guard
//
//  Created by Alexandr Bukharin on 16.11.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Foundation

struct EnvironmentImp: Environment {
	#if DEBUG
		let baseUrl = URL(string: "https://guardapi.co.uk/api/v1/")!
		let socketUrl = URL(string: "wss://guardapi.co.uk/connect")!
	#else
		let baseUrl = URL(string: "https://guardapi.co.uk/api/v1/")!
		let socketUrl = URL(string: "wss://guardapi.co.uk/connect")!
	#endif
}
