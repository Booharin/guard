//
//  Environment.swift
//  Guard
//
//  Created by Alexandr Bukharin on 16.11.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Foundation

protocol Environment {
	var baseUrl: URL { get }
	var socketUrl: URL { get }
}
