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
		let baseUrl = URL(string: "http://46.36.222.23:5000/api/v1/")!
		let socketUrl = URL(string: "ws://46.36.222.23:5000/connect")!
	#else
		let baseUrl = URL(string: "http://46.36.222.23:5000/api/v1/")!
		let socketUrl = URL(string: "ws://46.36.222.23:5000/connect")!
	#endif
}
