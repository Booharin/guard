//
//  ChatConversation.swift
//  Guard
//
//  Created by Alexandr Bukharin on 15.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

struct ChatConversation: Codable {
	let id: Int
	let dateCreated: String
	let userId: Int
	let lastMessage: String
	let appealId: Int?
	let userFirstName: String?
	let userLastName: String?
	let userPhoto: String?

	var fullName: String {
		guard
			let firstName = userFirstName,
			let lastName = userLastName else { return userFirstName ?? userLastName ?? "" }
		return "\(firstName) \(lastName)"
	}
}
