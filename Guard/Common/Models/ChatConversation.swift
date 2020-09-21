//
//  ChatConversation.swift
//  Guard
//
//  Created by Alexandr Bukharin on 15.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

struct ChatConversation: Decodable {
	let dateCreated: Double
	let companion: UserProfile
	let lastMessage: String
}
