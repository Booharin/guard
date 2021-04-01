//
//  SelectIssueCellViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 21.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxSwift

struct SelectIssueCellViewModel: ViewModel {
	var issueType: IssueType
	let toMainSubject: PublishSubject<(IssueType)>?
	let toCreateAppealSubject: PublishSubject<(IssueType)>?
	let toSubtyesSubject: PublishSubject<[IssueType]>?
	let tapSubject = PublishSubject<Any>()
	var view: SelectIssueTableViewCellProtocol!
	private let disposeBag = DisposeBag()

	init(issueType: IssueType,
		 toMainSubject: PublishSubject<(IssueType)>?,
		 toCreateAppealSubject: PublishSubject<IssueType>?,
		 toSubtyesSubject: PublishSubject<[IssueType]>?) {
		self.issueType = issueType
		self.toMainSubject = toMainSubject
		self.toCreateAppealSubject = toCreateAppealSubject
		self.toSubtyesSubject = toSubtyesSubject
	}

	func viewDidSet() {
		view.containerView
			.rx
			.tapGesture()
			.when(.recognized)
			.subscribe(onNext: { _ in
				if issueType.subIssueTypeList == nil {
					if let toMain = self.toMainSubject {
						toMain.onNext(self.issueType)
					} else {
						self.toCreateAppealSubject?.onNext(self.issueType)
					}
				} else {
					toSubtyesSubject?.onNext(issueType.subIssueTypeList ?? [])
				}
			}).disposed(by: disposeBag)

		view.issueTitle.text = issueType.title
		view.issueTitle.font = SFUIDisplay.regular.of(size: 16)
		view.issueTitle.textColor = Colors.mainTextColor
		view.issueTitle.numberOfLines = 0

		view.issuesubtitle.text = issueType.subtitle
		view.issuesubtitle.font = SFUIDisplay.light.of(size: 12)
		view.issuesubtitle.textColor = Colors.mainTextColor
		view.issuesubtitle.numberOfLines = 0

		if issueType.subtitle.isEmpty {
			view.issuesubtitle.snp.updateConstraints {
				$0.top.equalTo(self.view.issueTitle.snp.bottom)
			}
		}

		view.issueImageView.image = #imageLiteral(resourceName: "issue_icn")
	}

	func removeBindings() {}
}
