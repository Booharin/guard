//
//  ClientAppeal.swift
//  Guard
//
//  Created by Alexandr Bukharin on 09.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Foundation

struct ClientAppeal: Codable {
	let id: Int
    let title: String
    let appealDescription: String
	let clientId: Int
	let issueCode: Int
    let dateCreated: String
	let cityTitle: String
	let lawyerChoosed: Bool?

    init(clientAppealObject: ClientAppealObject) {
		self.id = Int(clientAppealObject.id)
        self.title = clientAppealObject.title ?? ""
        self.appealDescription = clientAppealObject.appealDescription ?? ""
        self.dateCreated = clientAppealObject.dateCreated ?? ""
		self.clientId = Int(clientAppealObject.clientId)
		self.issueCode = Int(clientAppealObject.issueCode)
		self.cityTitle = clientAppealObject.cityTitle ?? ""
		self.lawyerChoosed = clientAppealObject.lawyerChoosed
    }
}
