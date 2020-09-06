//
//  SelectIssueCellViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 21.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//
import RxSwift

struct SelectIssueCellViewModel: ViewModel {
	var clientIssue: ClientIssue
	let toMainSubject: PublishSubject<(ClientIssue)>?
	var view: SelectIssueTableViewCellProtocol!
	private let disposeBag = DisposeBag()
	
	init(clientIssue: ClientIssue,
		 toMainSubject: PublishSubject<(ClientIssue)>?) {
		self.clientIssue = clientIssue
		self.toMainSubject = toMainSubject
	}
	
	func viewDidSet() {
		view.containerView
			.rx
			.tapGesture()
			.skip(1)
			.subscribe(onNext: { _ in
				self.toMainSubject?.onNext(self.clientIssue)
			}).disposed(by: disposeBag)
		
		view.issueTitle.text = clientIssue.titleFromIssuetype
		view.issueTitle.font = SFUIDisplay.regular.of(size: 16)
		view.issueTitle.textColor = Colors.maintextColor
	}
	
	func removeBindings() {}
}