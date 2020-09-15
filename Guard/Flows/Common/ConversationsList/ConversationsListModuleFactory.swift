//
//  ConversationsListModuleFactory.swift
//  Guard
//
//  Created by Alexandr Bukharin on 15.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

final class ConversationsListModuleFactory {
	static func createModule() -> NavigationController {
		let router = ConversationsListRouter()
		let viewModel = ConversationsListViewModel(router: router)
		let controller = NavigationController(rootViewController:
			ConversationsListViewController(viewModel: viewModel)
		)
		router.navigationController = controller
		return controller
	}
}
