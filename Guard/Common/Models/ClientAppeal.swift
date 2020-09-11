//
//  ClientAppeal.swift
//  Guard
//
//  Created by Alexandr Bukharin on 09.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Foundation

struct ClientAppeal: Decodable {
    let issueType: String
    let title: String
    let appealDescription: String
    let dateCreate: Double
    
    init(clientAppealObject: ClientAppealObject) {
        self.issueType = clientAppealObject.issueType ?? ""
        self.title = clientAppealObject.title ?? ""
        self.appealDescription = clientAppealObject.appealDescription ?? ""
        self.dateCreate = clientAppealObject.dateCreate
    }
}
