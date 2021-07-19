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
		static let notReadCount = "not_read_count"
		static let userId = "user_id"
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
	enum MyTracker {
		static let sdkKey = "77074419708987656351"

		enum Events {
			static let userSentMessageFirstTime = "user_sent_message_first_time"
		}
	}
	enum Facebook {

		enum Events {
			static let userRegisterd = "user_registerd"
			static let userSentMessageFirstTime = "user_sent_message_first_time"
		}
	}
}
