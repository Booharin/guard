//
//  FilterIssuesViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 03.04.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit
import RxSwift

struct FilterIssuesCellViewModel: ViewModel {

	var view: FilterIssuesCellProtocol!

	private let animateDuration = 0.15
	private let issueType: IssueType
	private let reloadSubject: PublishSubject<Int>
	private let markSubIssueSelectedSubject: PublishSubject<SubIssueSelectedModel>

	private var disposeBag = DisposeBag()

	init(issueType: IssueType,
		 reloadSubject: PublishSubject<Int>,
		 markSubIssueSelectedSubject: PublishSubject<SubIssueSelectedModel>) {
		self.issueType = issueType
		self.reloadSubject = reloadSubject
		self.markSubIssueSelectedSubject = markSubIssueSelectedSubject
	}

	func viewDidSet() {
		view.subIssuesStackView.axis = .vertical
		view.subIssuesStackView.distribution = .equalSpacing
		view.subIssuesStackView.spacing = 0
		view.subIssuesStackView.backgroundColor = Colors.subIssuesListBackgroundColor

		if issueType.isSelected == true {
			issueType.subIssueTypeList?.forEach { subIssueType in
				// add subIssue view to stackView
				let selectSubIssueView = SelectSubIssueView(title: subIssueType.title,
															subtitle: subIssueType.subtitle,
															isSelected: subIssueType.isSelected ?? false)
				view.subIssuesStackView.addArrangedSubview(selectSubIssueView)
				selectSubIssueView
					.rx
					.tapGesture()
					.when(.recognized)
					.subscribe(onNext: { _ in
						selectSubIssueView.select(on: !selectSubIssueView.isSelected)
						let subIssueSelected = SubIssueSelectedModel(subIssueCode: subIssueType.subIssueCode ?? 0,
																	 isSelected: selectSubIssueView.isSelected)
						markSubIssueSelectedSubject.onNext(subIssueSelected)
					}).disposed(by: disposeBag)
			}

			view.chevronImageView.transform = view.chevronImageView.transform.rotated(by: .pi)
		}

		view.issueTitleView
			.rx
			.tapGesture()
			.when(.recognized)
			.subscribe(onNext: { _ in
				view.containerView.isUserInteractionEnabled = false

				UIView.animate(withDuration: self.animateDuration, animations: {
					self.view.containerView.alpha = 0.5
					view.chevronImageView.transform = view.chevronImageView.transform.rotated(by: .pi)
				}, completion: { _ in
					reloadSubject.onNext(issueType.issueCode)

					UIView.animate(withDuration: self.animateDuration, animations: {
						self.view.containerView.alpha = 1
					}, completion: { _ in
						view.containerView.isUserInteractionEnabled = true
					})
				})
			}).disposed(by: disposeBag)

		view.issueImageView.image = #imageLiteral(resourceName: "issue_icn")
		view.issueImageView.layer.cornerRadius = 15

		// title
		view.titleLabel.textColor = Colors.mainTextColor
		view.titleLabel.font = SFUIDisplay.regular.of(size: 16)
		view.titleLabel.numberOfLines = 0
		view.titleLabel.text = issueType.title//"Двамвамвамв вамвамвам вамвамвамвам вамвамвамвам ваамвамвамвам"//

		// description
		view.descriptionLabel.textColor = Colors.mainTextColor
		view.descriptionLabel.font = SFUIDisplay.light.of(size: 12)
		view.descriptionLabel.numberOfLines = 0
		view.descriptionLabel.text = issueType.subtitle

		// chevron
		view.chevronImageView.image = #imageLiteral(resourceName: "chevron_down_icn")

		// issue count label
		view.issuesCountLabel.backgroundColor = Colors.notReadMessagesBackgroundColor
		view.issuesCountLabel.textColor = Colors.whiteColor
		view.issuesCountLabel.font = SFUIDisplay.medium.of(size: 10)
		view.issuesCountLabel.layer.cornerRadius = 7
		view.issuesCountLabel.clipsToBounds = true
		view.issuesCountLabel.textAlignment = .center

		getIssuesCount()
	}

	private func getIssuesCount() {
		var issuesCount = 0
		issueType.subIssueTypeList?.forEach {
			if $0.isSelected == true {
				issuesCount += 1
			}
		}

		if issuesCount > 0 {
			if issuesCount > 9 {
				view.issuesCountLabel.text = "1.."
			} else {
				view.issuesCountLabel.text = "\(issuesCount)"
			}
		} else {
			view.issuesCountLabel.isHidden = true
		}
	}

	func removeBindings() {
		
	}
}
