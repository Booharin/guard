//
//  AppealFromListRouter.swift
//  Guard
//
//  Created by Alexandr Bukharin on 03.02.2021.
//  Copyright © 2021 ds. All rights reserved.
//

protocol AppealFromListRouterProtocol {
	func passageToClientProfile(profile: UserProfile)
}

final class AppealFromListRouter: BaseRouter, AppealFromListRouterProtocol {
	func passageToClientProfile(profile: UserProfile) {
		let controller = ClientFromAppealModuleFactory.createModule(clientProfile: profile,
																	navController: self.navigationController)
		self.navigationController?.pushViewController(controller, animated: true)
	}
}
