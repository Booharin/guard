//
//  ClientProfile.swift
//  Guard
//
//  Created by Alexandr Bukharin on 15.10.2020.
//  Copyright © 2020 ds. All rights reserved.
//

//struct ClientProfile: Decodable {
//	var id: Int
//	var email: String
//	var phone: String
//	var firstName: String
//	var lastName: String
//	var city: String
//	var country: String
//	var rate: Double
//	var photo: String
//	var dateCreated: Int
//	var reviews: [UserReview]?
//	var fullName: String {
//		return "\(firstName) \(lastName)"
//	}
//
//	init(clientProfileObject: ClientProfileObject) {
//		self.id = Int(clientProfileObject.id)
//		self.email = clientProfileObject.email ?? ""
//		self.phone = clientProfileObject.phone ?? ""
//		self.firstName = clientProfileObject.firstName ?? ""
//		self.lastName = clientProfileObject.lastName ?? ""
//		self.city = clientProfileObject.city ?? ""
//		self.country = clientProfileObject.country ?? ""
//		self.rate = clientProfileObject.rate
//		self.photo = clientProfileObject.photo ?? ""
//		self.dateCreated = Int(clientProfileObject.dateCreated)
//	}
//}
