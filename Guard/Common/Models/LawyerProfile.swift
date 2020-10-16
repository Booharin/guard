//
//  LawyerProfile.swift
//  Guard
//
//  Created by Alexandr Bukharin on 10.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

/// User model
struct LawyerProfile: Decodable {
	var id: Int
	var email: String
	var phone: String
	var firstName: String
	var lastName: String
	var city: String
	var country: String
	var rate: Double
	var photo: String
	var dateCreated: Int
	var reviews: [UserReview]?
	var issueTypes: [String]
	var fullName: String {
		return "\(firstName) \(lastName)"
	}
	
	init(lawyerProfileObject: LawyerProfileObject) {
		self.id = Int(lawyerProfileObject.id)
		self.email = lawyerProfileObject.email ?? ""
		self.phone = lawyerProfileObject.phone ?? ""
		self.firstName = lawyerProfileObject.firstName ?? ""
		self.lastName = lawyerProfileObject.lastName ?? ""
		self.city = lawyerProfileObject.city ?? ""
		self.country = lawyerProfileObject.country ?? ""
		self.rate = lawyerProfileObject.rate
		self.photo = lawyerProfileObject.photo ?? ""
		self.dateCreated = Int(lawyerProfileObject.dateCreated)
		self.issueTypes = lawyerProfileObject.issueTypes
	}
}
