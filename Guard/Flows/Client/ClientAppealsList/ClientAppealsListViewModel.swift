//
//  ClientAppealsListViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 09.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

final class ClientAppealsListViewModel: ViewModel, HasDependencies {
	var view: ClientAppealsListViewControllerProtocol!
	private let animationDuration = 0.15
	private var disposeBag = DisposeBag()
	private var appeals = [ClientAppeal]()
	private var router: ClientAppealsListRouterProtocol
	
	private let appealDict: [String : Any] = [
		"issueType": "drugs",
		"title": "Приняли с весом",
		"appealDescription": "Шёл, шёл, тут - `Стоять!, уголовный розыск`",
		"dateCreate": 1599719845.0
	]
	
	typealias Dependencies = HasLocalStorageService
	lazy var di: Dependencies = DI.dependencies
	
	init(router: ClientAppealsListRouterProtocol) {
		self.router = router
	}
	
	func viewDidSet() {
		getAppealsFromServer()
		
		// table view data source
		let section = SectionModel<String, ClientAppeal>(model: "",
														 items: appeals)
		let items = BehaviorSubject<[SectionModel]>(value: [section])
		items
			.bind(to: view.tableView
					.rx
					.items(dataSource: ClientAppealDataSource.dataSource(toAppealDescriptionSubject: router.toAppealDescriptionSubject)))
			.disposed(by: disposeBag)
		
		// add button
		view.addButtonView
			.rx
			.tapGesture()
			.when(.recognized)
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.addButtonView.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.addButtonView.alpha = 1
					})
				})
			})
			.subscribe(onNext: { [unowned self] _ in
				self.router.toSelectIssueSubject.onNext(())
			}).disposed(by: disposeBag)
		
		// greeting
		view.greetingLabel.font = Saira.light.of(size: 25)
		view.greetingLabel.textColor = Colors.mainTextColor
		view.greetingLabel.textAlignment = .center
		
		if let profile = di.localStorageService.getProfile(),
		   !profile.firstName.isEmpty {
			view.greetingLabel.text = "\("appeals.greeting.title".localized), \(profile.firstName)"
		} else {
			view.greetingLabel.text = "appeals.greeting.title".localized
		}
		
		view.greetingDescriptionLabel.font = Saira.light.of(size: 18)
		view.greetingDescriptionLabel.textColor = Colors.mainTextColor
		view.greetingDescriptionLabel.textAlignment = .center
		view.greetingDescriptionLabel.text = "appeals.greeting.description".localized
	}

	private func getAppealsFromServer() {
		let appealsArray = [
			appealDict,
			appealDict,
			appealDict,
			appealDict,
			appealDict,
			appealDict,
			appealDict,
			appealDict,
			appealDict,
			appealDict,
			appealDict,
			appealDict,
			appealDict,
			appealDict,
			appealDict
		]
		do {
			let jsonData = try JSONSerialization.data(withJSONObject: appealsArray,
													  options: .prettyPrinted)
			let appealsResponse = try JSONDecoder().decode([ClientAppeal].self, from: jsonData)
			self.appeals = appealsResponse
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
				self.view.updateTableView()
			})
		} catch {
			#if DEBUG
			print(error)
			#endif
		}
	}
	
	func removeBindings() {}
}
