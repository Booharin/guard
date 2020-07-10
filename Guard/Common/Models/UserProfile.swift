//
//  User.swift
//  Guard
//
//  Created by Alexandr Bukharin on 10.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

/// User type
enum UserType {
	case client
	case lawyer
}

/// User model
struct UserProfile {
	var userType: UserType
	
	init(userType: UserType) {
		self.userType = userType
	}
}
