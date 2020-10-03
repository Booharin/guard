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
	let tapSubject = PublishSubject<Any>()
	var view: SelectIssueTableViewCellProtocol!
	private let disposeBag = DisposeBag()

	init(issueType: IssueType,
		 toMainSubject: PublishSubject<(IssueType)>?,
		 toCreateAppealSubject: PublishSubject<IssueType>?) {
		self.issueType = issueType
		self.toMainSubject = toMainSubject
		self.toCreateAppealSubject = toCreateAppealSubject
	}

	func viewDidSet() {
		view.containerView
			.rx
			.tapGesture()
			.when(.recognized)
			.subscribe(onNext: { _ in
				if let toMain = self.toMainSubject {
					toMain.onNext(self.issueType)
				} else {
					self.toCreateAppealSubject?.onNext(self.issueType)
				}
			}).disposed(by: disposeBag)

		view.issueTitle.text = issueType.title
		view.issueTitle.font = SFUIDisplay.regular.of(size: 16)
		view.issueTitle.textColor = Colors.mainTextColor

		view.issuesubtitle.text = issueType.subtitle
		view.issuesubtitle.font = SFUIDisplay.light.of(size: 12)
		view.issuesubtitle.textColor = Colors.subtitleColor
		view.issuesubtitle.numberOfLines = 0

		view.issueImageView.image = #imageLiteral(resourceName: "divorce_icn")
	}

	func removeBindings() {}
}
