//
//  ClientProfileModuleFactory.swift
//  Guard
//
//  Created by Alexandr Bukharin on 20.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxSwift

final class ClientProfileModuleFactory {
	static func createModule(toAuthSubject: PublishSubject<Any>) -> NavigationController {
		let router = ClientProfileRouter(toAuthSubject: toAuthSubject)
		let viewModel = ClientProfileViewModel(router: router)
		let controller = NavigationController(rootViewController:
			ClientProfileViewController(viewModel: viewModel)
		)
		router.navigationController = controller
		return controller
	}
}
