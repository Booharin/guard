//
//  LawyerProfileModuleFactory.swift
//  Guard
//
//  Created by Alexandr Bukharin on 19.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import Foundation
import RxSwift

final class LawyerProfileModuleFactory {
	static func createModule(toAuthSubject: PublishSubject<Any>) -> NavigationController {
		let router = LawyerProfileRouter(toAuthSubject: toAuthSubject)
		let viewModel = LawyerProfileViewModel(lawyerProfileFromList: nil,
											   router: router)
		let controller = NavigationController(rootViewController: LawyerProfileViewController(viewModel: viewModel))
		router.navigationController = controller
		return controller
	}
}
