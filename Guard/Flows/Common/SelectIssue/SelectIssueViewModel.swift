//
//  SelectIssueViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 19.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

final class SelectIssueViewModel: ViewModel {
	var view: SelectIssueViewControllerProtocol!
	private var disposeBag = DisposeBag()
	private let animationDuration = 0.15
	var toMainSubject: PublishSubject<ClientIssue>?
    var toCreateAppealSubject: PublishSubject<ClientIssue>?

    init(toMainSubject: PublishSubject<ClientIssue>? = nil,
         toCreateAppealSubject: PublishSubject<ClientIssue>? = nil) {
		self.toMainSubject = toMainSubject
        self.toCreateAppealSubject = toCreateAppealSubject
	}

	var issues = [
		ClientIssue(issueType: "DRUGS"),
		ClientIssue(issueType: "DIVORCE"),
		ClientIssue(issueType: "REAL_ESTATE"),
		ClientIssue(issueType: "CAR_ACCIDENT")
	]
	
	func viewDidSet() {
		// back button
		view.backButtonView
			.rx
			.tapGesture()
			.skip(1)
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.backButtonView.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.backButtonView.alpha = 1
					})
				})
			})
			.subscribe(onNext: { [weak self] _ in
				self?.view.navController?.popViewController(animated: true)
			}).disposed(by: disposeBag)
		// title
		view.titleLabel.font = Saira.regular.of(size: 18)
		view.titleLabel.textColor = Colors.mainTextColor
		view.titleLabel.text = "new_appeal.title".localized
		
		// header
		view.headerTitleLabel.textColor = Colors.mainTextColor
		view.headerTitleLabel.textAlignment = .center
		view.headerSubtitleLabel.textColor = Colors.mainTextColor
		view.headerSubtitleLabel.textAlignment = .center
		view.headerSubtitleLabel.font = Saira.light.of(size: 18)

		if toMainSubject == nil {
			view.headerTitleLabel.font = Saira.light.of(size: 15)
			view.headerTitleLabel.text = "new_appeal.header.title".localized
			view.headerSubtitleLabel.text = "new_appeal.header.subtitle".localized
		} else {
			view.headerTitleLabel.font = Saira.light.of(size: 25)
			view.headerTitleLabel.text = "client.issue.header.title".localized
			view.headerSubtitleLabel.text = "client.issue.header.subtitle".localized
		}

		let section = SectionModel<String, ClientIssue>(model: "",
														items: issues)
		let items = BehaviorSubject<[SectionModel]>(value: [section])
		items
			.bind(to: view.tableView
				.rx
				.items(dataSource: SelectIssueDataSource.dataSource(toMainSubject: toMainSubject,
                                                                    toCreateAppealSubject: toCreateAppealSubject)))
			.disposed(by: disposeBag)

		// swipe to go back
		view.view
			.rx
			.swipeGesture(.right)
			.skip(1)
			.subscribe(onNext: { [unowned self] _ in
				if self.toMainSubject == nil {
					self.view.navController?.popViewController(animated: true)
				}
			}).disposed(by: disposeBag)
	}
	
	func removeBindings() {}
}
