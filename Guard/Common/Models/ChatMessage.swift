//
//  ChatMessage.swift
//  Guard
//
//  Created by Alexandr Bukharin on 15.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

struct ChatMessage: Decodable {
	let id: Int
	let chatId: Int
	let senderId: Int?
	let content: String
	let dateCreated: String
	let senderName: String
}
