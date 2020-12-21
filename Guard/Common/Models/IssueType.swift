//
//  IssueType.swift
//  Guard
//
//  Created by Alexandr Bukharin on 03.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Foundation

struct IssuesResponse: Decodable {
	let issuesTypes: [IssueType]
}

struct IssueType: Codable {
	let title: String
	let subtitle: String
	var titleEn: String?
	var subtitleEn: String?
	let issueCode: Int
	var locale: String?
	let subIssueTypeList: [IssueType]?
}
