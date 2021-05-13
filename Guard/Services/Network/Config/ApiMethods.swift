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
	static let getReviews = "review/getByReceiverId"
	// appeals
	static let clientAppeals = "appeal/client"
	static let createAppeal = "appeal/save"
	static let editAppeal = "appeal/edit"
	static let deleteAppeal = "appeal/remove"
	static let allAppeals = "lawyer/allappealcity"
	static let appealsByIssue = "common/iac"
	static let clientByAppealId = "common/client"
	static let getAppeal = "appeal/findAppeal"
	static let changeAppealStatus = "appeal/status"
	// chat
	static let createConversation = "chat/createconversation"
	static let createConversationByAppeal = "chat/createconversationByAppeal"
	static let getConversations = "chat/getconversations"
	static let getMessages = "chat/getmessages"
	static let deleteConversation = "chat/deleteconversation"
	static let messagesSetRead = "chat/setread"
	// review
	static let reviewUpload = "review/upload"
	// common
	static let countriesAndCities = "common/allcountries"
	static let issueTypes = "common/issues"
	// client
	static let editClient = "client/edit"
	// lawyer
	static let editLawyer = "lawyer/edit"
	// settings
	static let settings = "setting/settings"
}
