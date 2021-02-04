//
//  ChatRouter.swift
//  Guard
//
//  Created by Alexandr Bukharin on 04.02.2021.
//  Copyright © 2021 ds. All rights reserved.
//

protocol ChatRouterProtocol {
	func passageToAppealDescription(appeal: ClientAppeal)
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
}
