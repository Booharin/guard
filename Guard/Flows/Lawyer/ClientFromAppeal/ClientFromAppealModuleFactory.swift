//
//  ClientFromAppealModuleFactory.swift
//  Guard
//
//  Created by Alexandr Bukharin on 27.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit

final class ClientFromAppealModuleFactory {
	static func createModule(clientProfile: UserProfile,
							 navController: UINavigationController?) -> UIViewController {
		let router = ClientFromAppealRouter()
		let viewModel = ClientFromAppealViewModel(clientProfile: clientProfile,
											   router: router)
		let controller = ClientFromAppealViewController(viewModel: viewModel)
		router.navigationController = navController
		return controller
	}
}
