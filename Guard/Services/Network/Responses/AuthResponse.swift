//
//  AuthResponse.swift
//  Guard
//
//  Created by Alexandr Bukharin on 16.11.2020.
//  Copyright © 2020 ds. All rights reserved.
//

struct AuthResponse: Codable {
	let user: UserProfile
	let token: String
}
