//
//  UserReview.swift
//  Guard
//
//  Created by Alexandr Bukharin on 11.10.2020.
//  Copyright © 2020 ds. All rights reserved.
//

struct UserReview: Codable, Equatable {
	let reviewDescription: String?
	let rating: Double
	let dateCreated: String?
	let receiverId: Int
	let reviewId: Int
	let senderId: Int

	init(reviewObject: ReviewObject) {
		self.reviewDescription = reviewObject.reviewDescription
		self.rating = reviewObject.rating
		self.dateCreated = reviewObject.dateCreated ?? ""
		self.receiverId = Int(reviewObject.receiverId)
		self.reviewId = Int(reviewObject.reviewId)
		self.senderId = Int(reviewObject.senderId)
	}
}
