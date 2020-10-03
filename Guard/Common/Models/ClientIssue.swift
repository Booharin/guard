//
//  ClientIssue.swift
//  Guard
//
//  Created by Alexandr Bukharin on 03.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Foundation

//struct ClientIssue {
//	var issueType: String
//	
//	var titleFromIssuetype: String {
//		switch issueType {
//		case "DRUGS":
//			return "client.issue.drugs".localized
//		case "DIVORCE":
//			return "client.issue.divorce".localized
//		case "REAL_ESTATE":
//			return "client.issue.real_estate".localized
//		case "CAR_ACCIDENT":
//			return "client.issue.car_accident".localized
//		default:
//			return ""
//		}
//	}
//}

struct IssuesResponse: Decodable {
	let issuesTypes: [IssueType]
}

struct IssueType: Decodable {
	let title: String
	let subtitle: String
	let issueCode: String
	let subtypes: [IssueType]?
}
