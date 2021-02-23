//
//  Constants.swift
//  Wheels
//
//  Created by Alexandr Bukharin on 23.06.2020.
//  Copyright © 2020 ds. All rights reserved.
//

enum Constants {
	enum UserDefaultsKeys {
		static let isLogin = "isLogin"
		static let selectedIssues = "selected_issues"
	}
	enum KeyChainKeys {
		static let token = "network_token"
		static let email = "email"
		static let password = "password"
		static let phoneNumber = "phoneNumber"
		static let deviceToken = "deviceToken"
	}
	enum NotificationKeys {
		static let logout = "profile_logout"
		static let updateMessages = "update_messages"
	}
	enum ChatMessageKeys {
		static let senderName = "senderName"
		static let content = "content"
	}
}
