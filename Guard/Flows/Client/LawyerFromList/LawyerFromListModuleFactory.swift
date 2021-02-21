//
//  LawyerFromListModuleFactory.swift
//  Guard
//
//  Created by Alexandr Bukharin on 27.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

final class LawyerFromListModuleFactory {
	static func createModule(with lawyer: UserProfile,
							 isFromChat: Bool = false,
							 navController: UINavigationController?) -> UIViewController {
		let router = LawyerFromListRouter()
		let viewModel = LawyerFromListViewModel(lawyerProfile: lawyer,
												isFromChat: isFromChat,
												router: router)
		let controller = LawyerFromListViewController(viewModel: viewModel)
		router.navigationController = navController
		return controller
	}
}
