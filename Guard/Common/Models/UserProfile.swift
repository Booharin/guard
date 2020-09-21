//
//  User.swift
//  Guard
//
//  Created by Alexandr Bukharin on 10.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

/// User type
enum UserType: String {
	case client = "client"
	case lawyer = "lawyer"
}

/// User model
struct UserProfile: Decodable {
	var userType: String
	var email: String
	var firstName: String
	var lastName: String
	var city: String
    var rate: Double
	
	var fullName: String {
		return "\(firstName) \(lastName)"
	}
	
	init(userProfileObject: UserProfileObject) {
		self.userType = userProfileObject.userType ?? ""
		self.email = userProfileObject.email ?? ""
		self.firstName = userProfileObject.firstName ?? ""
		self.lastName = userProfileObject.lastName ?? ""
		self.city = userProfileObject.city ?? ""
        self.rate = userProfileObject.rate
	}
}
