//
//  UserReview.swift
//  Guard
//
//  Created by Alexandr Bukharin on 11.10.2020.
//  Copyright © 2020 ds. All rights reserved.
//

struct UserReview: Codable {
	let reviewDescription: String?
	let rating: Double
	let dateCreated: Int
	let profileId: Int
}
