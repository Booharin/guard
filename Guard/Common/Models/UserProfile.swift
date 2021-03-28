//
//  UserProfile.swift
//  Guard
//
//  Created by Alexandr Bukharin on 16.11.2020.
//  Copyright © 2020 ds. All rights reserved.
//
import Foundation

struct UserProfile: Codable {
	var id: Int
	var firstName: String?
	var lastName: String?
	var email: String?
	var phoneNumber: String?
	var photo: String?
	var cityCode: [Int]?
	var countryCode: [Int]?
	var dateCreated: String
	var averageRate: Double?
	var role: String
	var reviewList: [UserReview]?
	var subIssueTypes: [IssueType]?
	var subIssueCodes: [Int]?
	var complaint: Int?

	var fullName: String {
		guard
			let firstNameUser = firstName,
			let lastNameUser = lastName else { return firstName ?? lastName ?? "" }
		return "\(firstNameUser) \(lastNameUser)"
	}

	var userRole: UserRole {
		UserRole(rawValue: role) ?? .client
	}

	var settings: SettingsModel?

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
		self.subIssueCodes = userProfileObject.subIssueCodes ?? []
		self.complaint = Int(userProfileObject.complaint)
	}
}
