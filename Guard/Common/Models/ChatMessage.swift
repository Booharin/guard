//
//  ChatMessage.swift
//  Guard
//
//  Created by Alexandr Bukharin on 15.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

struct ChatMessage: Decodable {
	let text: String
	let dateCreated: Double
	let conversationId: Int
}
