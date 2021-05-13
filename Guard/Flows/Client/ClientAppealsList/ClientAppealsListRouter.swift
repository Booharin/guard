//
//  ClientAppealsListRouter.swift
//  Guard
//
//  Created by Alexandr Bukharin on 11.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxSwift
import RxCocoa

protocol ClientAppealsListRouterProtocol {
	var toAppealDescriptionSubject: PublishSubject<ClientAppeal> { get }
	var toSelectIssueSubject: PublishSubject<Any> { get }
	var appealCreatedSubject: PublishSubject<Any> { get }
}

final class ClientAppealsListRouter: BaseRouter, ClientAppealsListRouterProtocol {
	private var disposeBag = DisposeBag()
	let toAppealDescriptionSubject = PublishSubject<ClientAppeal>()
	let toSelectIssueSubject = PublishSubject<Any>()
	let appealCreatedSubject = PublishSubject<Any>()

	override init() {
		super.init()
		createTransitions()
	}

	private func createTransitions() {
		// to appeal description
		toAppealDescriptionSubject
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [unowned self] appeal in
				self.toAppealDescription(appeal)
			})
			.disposed(by: disposeBag)

		// to select issue & than appeal creating
		toSelectIssueSubject
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [unowned self] _ in
				self.toSelectIssue()
			})
			.disposed(by: disposeBag)
	}

	private func toAppealDescription(_ appeal: ClientAppeal) {
		let toAppealCreatingController = AppealViewController(viewModel: AppealViewModel(appeal: appeal)
		)
		self.navigationController?.pushViewController(toAppealCreatingController, animated: true)
	}

	private func toSelectIssue() {
		let toCreateAppealSubject = PublishSubject<IssueType>()
		toCreateAppealSubject
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [unowned self] issueType in
				self.toAppealCreating(issueType, appealCreatedSubject: self.appealCreatedSubject)
			})
			.disposed(by: disposeBag)
		
		let selectIssueController = SelectIssueViewController(viewModel:
																SelectIssueViewModel(toCreateAppealSubject: toCreateAppealSubject))
		selectIssueController.hidesBottomBarWhenPushed = true
		
		self.navigationController?.pushViewController(selectIssueController, animated: true)
	}

	private func toAppealCreating(_ issueType: IssueType,
								  appealCreatedSubject: PublishSubject<Any>) {
		let toAppealCreatingController = AppealCreatingViewController(
			viewModel: AppealCreatingViewModel(issueType: issueType,
											   appealCreatedSubject: appealCreatedSubject)
		)
		self.navigationController?.pushViewController(toAppealCreatingController, animated: true)
	}
}
