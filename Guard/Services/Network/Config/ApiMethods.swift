//
//  ApiMethods.swift
//  Guard
//
//  Created by Alexandr Bukharin on 16.11.2020.
//  Copyright © 2020 ds. All rights reserved.
//

enum ApiMethods {
	// auth
	static let login = "auth/login"
	static let forgotPassword = "common/forgot"
	static let changePassword = "common/change"
	static let register = "common/register"
	// lawyers
	static let getLawyers = "common/lawyers"
	static let getAllLawyers = "client/alllawyers"
	static let getLawyer = "common/lawyer"
	// appeals
	static let clientAppeals = "appeal/client"
	static let createAppeal = "appeal/save"
	static let editAppeal = "appeal/edit"
	static let deleteAppeal = "appeal/remove"
	static let allAppeals = "lawyer/allappealcity"
	static let appealsByIssue = "common/iac"
	// chat
	static let getConversations = "chat/getconversations"
	static let getMessages = "chat/getmessages"
	// common
	static let countriesAndCities = "common/allcountries"
	static let issueTypes = "common/issues"
	// client
	static let editClient = "client/edit"
	// settings
	static let settings = "setting/settings"
}
