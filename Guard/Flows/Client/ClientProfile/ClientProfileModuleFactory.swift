//
//  ClientProfileModuleFactory.swift
//  Guard
//
//  Created by Alexandr Bukharin on 20.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

final class ClientProfileModuleFactory {
	static func createModule() -> NavigationController {
		let router = ClientProfileRouter()
		let viewModel = ClientProfileViewModel(router: router)
		let controller = NavigationController(rootViewController:
			ClientProfileViewController(viewModel: viewModel)
		)
		router.navigationController = controller
		return controller
	}
}
