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
	let toCreateAppealSubject: PublishSubject<(ClientIssue)>?
	let tapSubject = PublishSubject<Any>()
	var view: SelectIssueTableViewCellProtocol!
	private let disposeBag = DisposeBag()
	
	init(clientIssue: ClientIssue,
		 toMainSubject: PublishSubject<(ClientIssue)>?,
		 toCreateAppealSubject: PublishSubject<ClientIssue>?) {
		self.clientIssue = clientIssue
		self.toMainSubject = toMainSubject
		self.toCreateAppealSubject = toCreateAppealSubject
	}
	
	func viewDidSet() {
		tapSubject
			.subscribe(onNext: { _ in
				if let toMain = self.toMainSubject {
					toMain.onNext(self.clientIssue)
				} else {
					self.toCreateAppealSubject?.onNext(self.clientIssue)
				}
			}).disposed(by: disposeBag)
		
		view.issueTitle.text = clientIssue.titleFromIssuetype
		view.issueTitle.font = SFUIDisplay.regular.of(size: 16)
		view.issueTitle.textColor = Colors.mainTextColor
		
		view.issueImageView.image = #imageLiteral(resourceName: "divorce_icn")
	}
	
	func removeBindings() {}
}
