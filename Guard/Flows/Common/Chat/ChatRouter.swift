//
//  ChatRouter.swift
//  Guard
//
//  Created by Alexandr Bukharin on 04.02.2021.
//  Copyright © 2021 ds. All rights reserved.
//

protocol ChatRouterProtocol {
	func passageToAppealDescription(appeal: ClientAppeal)
	func passageToClientProfile(with profile: UserProfile)
	func passageToLawyer(with userProfile: UserProfile)
}

final class ChatRouter: BaseRouter, ChatRouterProtocol {
	func passageToAppealDescription(appeal: ClientAppeal) {
		let router = AppealFromListRouter()
		router.navigationController = navigationController

		let appealViewModel = AppealFromListViewModel(appeal: appeal,
													  isFromChat: true,
													  router: router)

		let appealViewController = AppealFromListViewController(viewModel: appealViewModel)
		navigationController?.pushViewController(appealViewController, animated: true)
	}

	func passageToClientProfile(with profile: UserProfile) {
		let controller = ClientFromAppealModuleFactory.createModule(clientProfile: profile,
																	navController: self.navigationController)
		self.navigationController?.pushViewController(controller, animated: true)
	}

	func passageToLawyer(with userProfile: UserProfile) {
		let controller = LawyerFromListModuleFactory.createModule(with: userProfile,
																  isFromChat: true,
																  navController: navigationController)
		navigationController?.pushViewController(controller, animated: true)
	}
}
