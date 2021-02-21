//
//  SettingsModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 18.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

struct SettingsModel: Codable {
	let id: Int
	var isPhoneVisible: Bool
	var isEmailVisible: Bool
	var isChatEnabled: Bool

	init(id: Int,
		 isPhoneVisible: Bool,
		 isEmailVisible: Bool,
		 isChatEnabled: Bool) {
		self.id = id
		self.isPhoneVisible = isPhoneVisible
		self.isEmailVisible = isEmailVisible
		self.isChatEnabled = isChatEnabled
	}

	init(settingsObject: SettingsObject) {
		self.id = Int(settingsObject.id)
		self.isPhoneVisible = settingsObject.isPhoneVisible
		self.isEmailVisible = settingsObject.isEmailVisible
		self.isChatEnabled = settingsObject.isChatEnabled
	}
}
