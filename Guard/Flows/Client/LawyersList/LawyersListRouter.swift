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
	func passToLawyer(with userProfile: UserProfile)
	func presentFilterScreenViewController(subIssuesCodes: [Int],
										   filterIssuesSubject: PublishSubject<[Int]>)
}

final class LawyersListRouter: BaseRouter, LawyerListRouterProtocol {

	func passToLawyer(with userProfile: UserProfile) {
		let controller = LawyerFromListModuleFactory.createModule(with: userProfile,
																  navController: navigationController)
		navigationController?.pushViewController(controller, animated: true)
	}

	func presentFilterScreenViewController(subIssuesCodes: [Int],
										   filterIssuesSubject: PublishSubject<[Int]>) {
		let controller = FilterScreenModuleFactory.createModule(subIssuesCodes: subIssuesCodes,
																selectedIssuesSubject: filterIssuesSubject)
		navigationController?.present(controller, animated: true)
	}
}
