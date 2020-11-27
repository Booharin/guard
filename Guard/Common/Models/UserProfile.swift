//
//  UserProfile.swift
//  Guard
//
//  Created by Alexandr Bukharin on 16.11.2020.
//  Copyright © 2020 ds. All rights reserved.
//

struct UserProfile: Codable {
	var id: Int
	var firstName: String?
	var lastName: String?
	var email: String?
	var phoneNumber: String?
	var photo: String?
	var cityCode: [Int]
	var countryCode: [Int]
	var dateCreated: String
	var averageRate: Double?
	var role: String
	var reviewList: [UserReview]?
	var issueTypes: [String]?
	var fullName: String {
		return "\(firstName ?? "") \(lastName ?? "")"
	}
	var userRole: UserRole {
		UserRole(rawValue: role) ?? .client
	}

	init(userProfileObject: UserProfileObject) {
		self.id = Int(userProfileObject.id)
		self.firstName = userProfileObject.firstName ?? ""
		self.lastName = userProfileObject.lastName ?? ""
		self.email = nil
		self.photo = userProfileObject.photo ?? ""
		self.cityCode = userProfileObject.cityCode ?? []
		self.countryCode = userProfileObject.countryCode ?? []
		self.dateCreated = userProfileObject.dateCreated ?? ""
		self.averageRate = userProfileObject.averageRate
		self.role = userProfileObject.role ?? ""
		self.issueTypes = userProfileObject.issueTypes
	}
}
