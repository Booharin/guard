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
		HasAppealsNetworkService
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
	private let filterIssuesSubject = PublishSubject<[Int]>()
	private var dataSourceSubject: BehaviorSubject<[SectionModel<String, ClientAppeal>]>?

	private var selectedSubIssuesCodes = [Int]()
	private var currentCityTitle = ""

	private var nextPage = 0
	private let pageSize = 20
	private var isAllappealsDownloaded = false

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

		view.tableView
			.rx
			.prefetchRows
			.filter { _ in
				self.isAllappealsDownloaded == false
			}
			.subscribe(onNext: { [unowned self] rows in
				if rows.contains([0, 0]) {
					if self.selectedSubIssuesCodes.isEmpty {
						self.appealsListSubject?.onNext(())
					} else {
						self.filterIssuesSubject.onNext(self.selectedSubIssuesCodes)
					}
				}
			})
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
				self.router.presentFilterScreenViewController(subIssuesCodes: selectedSubIssuesCodes,
															  filterIssuesSubject: filterIssuesSubject)
			}).disposed(by: disposeBag)

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

		// empty appeals label
		view.emptyAppealsLabel.isHidden = true
		view.emptyAppealsLabel.textAlignment = .center
		view.emptyAppealsLabel.numberOfLines = 0
		view.emptyAppealsLabel.font = Saira.regular.of(size: 16)
		view.emptyAppealsLabel.textColor = Colors.subtitleColor
		view.emptyAppealsLabel.text = "appeals.empty.title".localized

		appealsListSubject = PublishSubject<Any>()
		appealsListSubject?
			.asObservable()
			.flatMap { [unowned self] _ in
				self.di.appealsNetworkService.getAppeals(by: nil,
														 city: self.currentCityTitle,
														 page: self.nextPage,
														 pageSize: self.pageSize)
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

		view.loadingView.play()
		appealsListSubject?.onNext(())

		filterIssuesSubject
			.do(onNext: { [weak self] _ in
				self?.view.loadingView.play()
			})
			.do(onNext: { [weak self] subIssuesCodes in
				if subIssuesCodes != self?.selectedSubIssuesCodes {
					self?.nextPage = 0
					self?.appeals.removeAll()
				}
				// save selected issues
				self?.selectedSubIssuesCodes = subIssuesCodes
			})
			.flatMap { [unowned self] subIssuesCodes in
				self.di.appealsNetworkService.getAppeals(by: subIssuesCodes,
														 city: self.currentCityTitle,
														 page: self.nextPage,
														 pageSize: self.pageSize)
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
			})
			.disposed(by: disposeBag)
	}

	private func update(with appeals: [ClientAppeal]) {
		self.appeals.append(contentsOf:
								appeals.filter { ($0.lawyerChoosed ?? false) == false }
		)
		let section = SectionModel<String, ClientAppeal>(model: "",
														items: self.appeals)
		dataSourceSubject?.onNext([section])

		if appeals.isEmpty,
			self.appeals.isEmpty {
			view.emptyAppealsLabel.isHidden = false
		} else {
			view.emptyAppealsLabel.isHidden = true
		}

		if self.view.tableView.contentSize.height + 200 < self.view.tableView.frame.height {
			self.view.tableView.isScrollEnabled = false
		} else {
			self.view.tableView.isScrollEnabled = true
		}

		if appeals.isEmpty {
			isAllappealsDownloaded = true
		} else {
			isAllappealsDownloaded = false
		}

		nextPage += 1
	}

	func removeBindings() {}
}
