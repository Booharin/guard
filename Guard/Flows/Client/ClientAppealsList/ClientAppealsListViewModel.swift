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
	var appealsListSubject: PublishSubject<Any>?
	private var dataSourceSubject: BehaviorSubject<[SectionModel<String, ClientAppeal>]>?

	typealias Dependencies =
		HasLocalStorageService &
		HasAppealsNetworkService
	lazy var di: Dependencies = DI.dependencies

	init(router: ClientAppealsListRouterProtocol) {
		self.router = router
	}

	func viewDidSet() {
		// table view data source
		let section = SectionModel<String, ClientAppeal>(model: "",
														 items: appeals)
		let dataSource = ClientAppealDataSource.dataSource(toAppealDescriptionSubject: router.toAppealDescriptionSubject)
		dataSource.canEditRowAtIndexPath = { dataSource, indexPath  in
			  return true
		}
		dataSourceSubject = BehaviorSubject<[SectionModel]>(value: [section])
		dataSourceSubject?
			.bind(to: view.tableView
					.rx
					.items(dataSource: dataSource))
			.disposed(by: disposeBag)
		
		view.tableView.rx.itemDeleted
			.asObservable()
			.filter { [unowned self] indexPath in
				indexPath.row < appeals.count
			}
			.flatMap { [unowned self] indexPath in
				self.di.appealsNetworkService.deleteAppeal(id: appeals[indexPath.row].id)
			}
			.flatMap { [unowned self] _ in
				self.di.appealsNetworkService.getClientAppeals(by: di.localStorageService.getCurrenClientProfile()?.id ?? 0)
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				self?.view.loadingView.stop()
				switch result {
					case .success(let appeals):
						self?.update(with: appeals)
					case .failure(let error):
						//TODO: - обработать ошибку
						print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)

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
		
		if let profile = di.localStorageService.getCurrenClientProfile(),
		   let firstName = profile.firstName,
		   !firstName.isEmpty {
			view.greetingLabel.text = "\("appeals.greeting.title".localized), \(firstName)"
		} else {
			view.greetingLabel.text = "appeals.greeting.title".localized
		}
		
		view.greetingDescriptionLabel.font = Saira.light.of(size: 18)
		view.greetingDescriptionLabel.textColor = Colors.mainTextColor
		view.greetingDescriptionLabel.textAlignment = .center
		view.greetingDescriptionLabel.text = "appeals.greeting.description".localized

		appealsListSubject = PublishSubject<Any>()
		appealsListSubject?
			.asObservable()
			.flatMap { [unowned self] _ in
				self.di.appealsNetworkService.getClientAppeals(by: di.localStorageService.getCurrenClientProfile()?.id ?? 0)
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				self?.view.loadingView.stop()
				switch result {
					case .success(let appeals):
						self?.update(with: appeals)
					case .failure(let error):
						//TODO: - обработать ошибку
						print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)
	}

	private func update(with appeals: [ClientAppeal]) {
		self.appeals = appeals
		let section = SectionModel<String, ClientAppeal>(model: "",
														items: appeals)
		dataSourceSubject?.onNext([section])

		if self.view.tableView.contentSize.height + 200 < self.view.tableView.frame.height {
			self.view.tableView.isScrollEnabled = false
		} else {
			self.view.tableView.isScrollEnabled = true
		}
	}

	func removeBindings() {}
}
