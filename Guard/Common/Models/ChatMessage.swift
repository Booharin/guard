//
//  ChatMessage.swift
//  Guard
//
//  Created by Alexandr Bukharin on 15.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

enum MessageType: String {
	case incoming = "incoming"
	case outgoing = "outgoing"
}

struct ChatMessage: Decodable {
	let text: String
	let dateCreated: Double
	let conversationId: Int
	let eventOwner: String
	
	var messageType: MessageType {
		switch eventOwner {
		case "incoming":
			return .incoming
		case "outgoing":
			return .outgoing
		default:
			return .outgoing
		}
	}
}
