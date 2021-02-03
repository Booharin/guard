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
	func passToSelectIssue(selectIssueSubject: PublishSubject<IssueType>, lawyerFirstName: String?)
}

final class EditProfileRouter: BaseRouter, EditProfileRouterProtocol {
	weak var view: EditLawyerProfileViewControllerProtocol?

	func passToSelectIssue(selectIssueSubject: PublishSubject<IssueType>, lawyerFirstName: String?) {
		let controller = SelectIssueViewController(viewModel: SelectIssueViewModel(toMainSubject: selectIssueSubject,
																				   userRole: .lawyer,
																				   lawyerFirstName: lawyerFirstName))
		view?.navController?.pushViewController(controller, animated: true)
	}
}
