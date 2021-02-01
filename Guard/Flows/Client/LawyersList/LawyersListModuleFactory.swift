//
//  LawyersListModuleFactory.swift
//  Guard
//
//  Created by Alexandr Bukharin on 10.12.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Foundation
import RxSwift

final class LawyersListModuleFactory {
	static func createModule(toChatWithLawyer: PublishSubject<Int>) -> NavigationController {
		let router = LawyersListRouter()
		let viewModel = LawyersListViewModel(router: router,
											 toChatWithLawyer: toChatWithLawyer)
		let controller = NavigationController(rootViewController: LawyersListViewController(viewModel: viewModel))
		router.navigationController = controller
		return controller
	}
}
