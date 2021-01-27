//
//  LawyersListRouter.swift
//  Guard
//
//  Created by Alexandr Bukharin on 10.12.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Foundation

protocol LawyerListRouterProtocol {
	func passToLawyer(with userProfile: UserProfile)
}

final class LawyersListRouter: BaseRouter, LawyerListRouterProtocol {

	func passToLawyer(with userProfile: UserProfile) {
		let controller = LawyerFromListModuleFactory.createModule(with: userProfile,
																  navController: navigationController)
		navigationController?.pushViewController(controller, animated: true)
	}
}
