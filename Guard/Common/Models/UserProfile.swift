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
	var id: Int
	var userType: String
	var email: String
	var phone: String
	var firstName: String
	var lastName: String
	var city: String
	var country: String
    var rate: Double
	var photo: String
	var reviews: [UserReview]?
	var fullName: String {
		return "\(firstName) \(lastName)"
	}
	
	init(userProfileObject: UserProfileObject) {
		self.id = Int(userProfileObject.id)
		self.userType = userProfileObject.userType ?? ""
		self.email = userProfileObject.email ?? ""
		self.phone = userProfileObject.phone ?? ""
		self.firstName = userProfileObject.firstName ?? ""
		self.lastName = userProfileObject.lastName ?? ""
		self.city = userProfileObject.city ?? ""
		self.country = userProfileObject.country ?? ""
        self.rate = userProfileObject.rate
		self.photo = userProfileObject.photo ?? ""
	}
}
