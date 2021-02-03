//
//  AppealsListViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 19.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

final class AppealsListViewModel:
	ViewModel,
	HasDependencies {

	var view: AppealsListViewControllerProtocol!
	private let animationDuration = 0.15
	typealias Dependencies =
		HasLocalStorageService &
		HasKeyChainService &
		HasAppealsNetworkService &
		HasFilterViewService
	lazy var di: Dependencies = DI.dependencies
	var clientProfile: UserProfile? {
		di.localStorageService.getCurrenClientProfile()
	}
	private var cities: [String] {
		return di.localStorageService.getRussianCities().map { $0.title }
	}
	private var appeals = [ClientAppeal]()
	private var router: AppealsListRouterProtocol
	private let disposeBag = DisposeBag()
	var appealsListSubject: PublishSubject<Any>?
	private var dataSourceSubject: BehaviorSubject<[SectionModel<String, ClientAppeal>]>?
	var selectedIssues = [Int]()
	private var currentCityTitle = ""

	init(router: AppealsListRouterProtocol) {
		self.router = router
	}
	func viewDidSet() {
		// table view data source
		let section = SectionModel<String, ClientAppeal>(model: "",
														 items: appeals)
		dataSourceSubject = BehaviorSubject<[SectionModel]>(value: [section])
		dataSourceSubject?
			.bind(to: view.tableView
					.rx
					.items(dataSource: ClientAppealDataSource.dataSource(toAppealDescriptionSubject: router.toAppealDescriptionSubject)))
			.disposed(by: disposeBag)

		// back button
		view.filterButtonView
			.rx
			.tapGesture()
			.when(.recognized)
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.filterButtonView.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.filterButtonView.alpha = 1
					})
				})
			})
			.subscribe(onNext: { [unowned self] _ in
				self.di.filterViewService.showFilterView(with: selectedIssues)
			}).disposed(by: disposeBag)

		di.filterViewService.selectedIssuesSubject
			.do(onNext: { [weak self] _ in
				self?.view.loadingView.startAnimating()
			})
			.do(onNext: { [weak self] issues in
				// save selected issues
				self?.selectedIssues = issues
			})
			.flatMap { [unowned self] issues in
				self.di.appealsNetworkService.getAppeals(by: issues,
														 city: self.view.titleLabel.text ?? "")
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				self?.view.loadingView.stopAnimating()
				switch result {
					case .success(let lawyers):
						self?.update(with: lawyers)
					case .failure(let error):
						//TODO: - обработать ошибку
						print(error.localizedDescription)
				}
			})
			.disposed(by: disposeBag)

		// back button
		view.titleView
			.rx
			.tapGesture()
			.when(.recognized)
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.titleView.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.titleView.alpha = 1
					})
				})
				self.view.showActionSheet(with: self.cities)
			})
			.subscribe(onNext: { _ in
				//
			}).disposed(by: disposeBag)

		view.titleLabel.font = Saira.semiBold.of(size: 16)
		view.titleLabel.textColor = Colors.mainTextColor
		if let profile = di.localStorageService.getCurrenClientProfile() {
			di.localStorageService.getRussianCities().forEach() { city in
				if city.cityCode == profile.cityCode?.first {
					if let locale = Locale.current.languageCode, locale == "ru" {
						view.titleLabel.text = city.title
					} else {
						view.titleLabel.text = city.titleEn
					}

					currentCityTitle = city.title
				}
			}
		}

		appealsListSubject = PublishSubject<Any>()
		appealsListSubject?
			.asObservable()
			.flatMap { [unowned self] _ in
				self.di.appealsNetworkService.getAppeals(by: self.currentCityTitle)
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				self?.view.loadingView.stopAnimating()
				switch result {
					case .success(let appeals):
						self?.update(with: appeals)
					case .failure(let error):
						//TODO: - обработать ошибку
						print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)

		view.loadingView.startAnimating()
		appealsListSubject?.onNext(())
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
