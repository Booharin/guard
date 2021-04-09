//
//  LawyersListModuleFactory.swift
//  Guard
//
//  Created by Alexandr Bukharin on 10.12.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Foundation

final class LawyersListModuleFactory {
	static func createModule(issueType: IssueType?) -> NavigationController {
		let router = LawyersListRouter()
		let viewModel = LawyersListViewModel(router: router, issueType: issueType)
		let controller = NavigationController(rootViewController: LawyersListViewController(viewModel: viewModel))
		router.navigationController = controller
		return controller
	}
}
