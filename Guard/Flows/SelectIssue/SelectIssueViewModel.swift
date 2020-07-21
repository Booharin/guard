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
	
	var issues = [
		"Проблемы с нароктиками", "Развод", "Земельные вопросы", "ДТП"
	]
	
	func viewDidSet() {
		var section = TableViewSection(items: [], header: "")
		issues.forEach() { issue in
			section.items.append(TableViewItem(title: issue))
		}
		let items = BehaviorSubject<[TableViewSection]>(value: [section])
		items
			.bind(to: view.tableView.rx.items(dataSource: SelectIssueDataSource.dataSource()))
			.disposed(by: disposeBag)
	}
	
	func removeBindings() {}
}
