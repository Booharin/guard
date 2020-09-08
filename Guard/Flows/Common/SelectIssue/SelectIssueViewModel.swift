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
	let toMainSubject: PublishSubject<ClientIssue>

	init(toMainSubject: PublishSubject<ClientIssue>) {
		self.toMainSubject = toMainSubject
	}

	var issues = [
		ClientIssue(issueType: "DRUGS"),
		ClientIssue(issueType: "DIVORCE"),
		ClientIssue(issueType: "REAL_ESTATE"),
		ClientIssue(issueType: "CAR_ACCIDENT")
	]
	
	func viewDidSet() {
		let section = SectionModel<String, ClientIssue>(model: "",
														items: issues)
		let items = BehaviorSubject<[SectionModel]>(value: [section])
		items
			.bind(to: view.tableView
				.rx
				.items(dataSource: SelectIssueDataSource.dataSource(toMainSubject: toMainSubject)))
			.disposed(by: disposeBag)
	}
	
	func update(with issues: [ClientIssue]) {
		self.issues = issues
		DispatchQueue.main.async {
			self.view.tableView.reloadData()
		}
		
		if self.view.tableView.contentSize.height < self.view.tableView.frame.height {
            self.view.tableView.isScrollEnabled = false
		} else {
			self.view.tableView.isScrollEnabled = true
		}
	}
	
	func removeBindings() {}
}
