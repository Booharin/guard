//
//  AppealsListModuleFactory.swift
//  Guard
//
//  Created by Alexandr Bukharin on 19.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

final class AppealsListModuleFactory {
	static func createModule() -> NavigationController {
		let router = AppealsListRouter()
		let viewModel = AppealsListViewModel(router: router)
		let controller = NavigationController(rootViewController: AppealsListViewController(viewModel: viewModel))
		router.navigationController = controller
		return controller
	}
}
