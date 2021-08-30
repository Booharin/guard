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

struct IssueType: Codable, Equatable {
	let title: String
	var titleEn: String?
	let subtitle: String
	var subtitleEn: String?
	let issueCode: Int
	let subIssueCode: Int?
	var locale: String?
	var subIssueTypeList: [IssueType]?
	let image: String?

	var isSelected: Bool?

	mutating func select(on: Bool) {
		isSelected = on
	}

	mutating func selectBy(index: Int,
						   on: Bool) {
		subIssueTypeList?[index].select(on: on)
	}
}
