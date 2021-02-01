//
//  LawyersListRouter.swift
//  Guard
//
//  Created by Alexandr Bukharin on 10.12.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Foundation
import RxSwift

protocol LawyerListRouterProtocol {
	func passToLawyer(with userProfile: UserProfile,
					  toChatWithLawyer: PublishSubject<Int>)
}

final class LawyersListRouter: BaseRouter, LawyerListRouterProtocol {

	func passToLawyer(with userProfile: UserProfile,
					  toChatWithLawyer: PublishSubject<Int>) {
		let controller = LawyerFromListModuleFactory.createModule(with: userProfile,
																  navController: navigationController,
																  toChatWithLawyer: toChatWithLawyer)
		navigationController?.pushViewController(controller, animated: true)
	}
}
