//
//  EditProfileRouter.swift
//  Guard
//
//  Created by Alexandr Bukharin on 23.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import RxSwift

protocol EditProfileRouterProtocol {
	var view: EditLawyerProfileViewControllerProtocol? { get set }
	func presentFilterScreenViewController(subIssuesCodes: [Int],
										   filterIssuesSubject: PublishSubject<[Int]>)
}

final class EditProfileRouter: BaseRouter, EditProfileRouterProtocol {
	weak var view: EditLawyerProfileViewControllerProtocol?

	func presentFilterScreenViewController(subIssuesCodes: [Int],
										   filterIssuesSubject: PublishSubject<[Int]>) {
		let controller = FilterScreenModuleFactory.createModule(subIssuesCodes: subIssuesCodes,
																selectedIssuesSubject: filterIssuesSubject)
		view?.navController?.present(controller, animated: true)
	}
}
