//
//  LawyersListViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 03.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class LawyersListViewModel: ViewModel, HasDependencies {
	var view: LawyersListViewControllerProtocol!
	private let animationDuration = 0.15
	private var disposeBag = DisposeBag()

	private var lawyersListSubject: PublishSubject<Any>?
	private var updateLayersListSubject: PublishSubject<Int>?

	private var router: LawyerListRouterProtocol
	private var selectedIssues = [Int]()
	private var currentCity: CityModel?
	private var issueType: IssueType?

	private var cities: [String] {
		return di.localStorageService.getRussianCities().map { $0.title }
	}

	var lawyers = [UserProfile]()

	typealias Dependencies =
		HasLocationService &
		HasLocalStorageService &
		HasLawyersNetworkService &
		HasFilterViewService
	lazy var di: Dependencies = DI.dependencies

	private var toLawyerSubject: PublishSubject<UserProfile>?
	private var dataSourceSubject: BehaviorSubject<[SectionModel<String, UserProfile>]>?

	init(router: LawyerListRouterProtocol,
		 issueType: IssueType?) {
		self.router = router
		self.issueType = issueType
	}

	func viewDidSet() {
		toLawyerSubject = PublishSubject<UserProfile>()
		toLawyerSubject?
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { profile in
				self.router.passToLawyer(with: profile)
			})
			.disposed(by: disposeBag)
		// table view data source
		let section = SectionModel<String, UserProfile>(model: "",
														items: lawyers)
		dataSourceSubject = BehaviorSubject<[SectionModel]>(value: [section])
		dataSourceSubject?
			.bind(to: view.tableView
					.rx
					.items(dataSource: LawyersListDataSource.dataSource(toLawyerSubject: toLawyerSubject)))
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
				self.di.lawyersNetworkService.getLawyers(by: issues,
														 city: currentCity?.title ?? "")
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
					currentCity = city
				}
			}
		}

		// empty lawyers label
		view.emptyLawyersLabel.isHidden = true
		view.emptyLawyersLabel.textAlignment = .center
		view.emptyLawyersLabel.numberOfLines = 0
		view.emptyLawyersLabel.font = Saira.regular.of(size: 16)
		view.emptyLawyersLabel.textColor = Colors.subtitleColor
		view.emptyLawyersLabel.text = "lawyers.empty.title".localized

		lawyersListSubject = PublishSubject<Any>()
		lawyersListSubject?
			.asObservable()
			.flatMap { [unowned self] _ in
				self.di.lawyersNetworkService.getAllLawyers(from: currentCity?.title ?? "")
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
			}).disposed(by: disposeBag)

		view.loadingView.startAnimating()

		// MARK: - Check if issue type selected from client registration
		if issueType == nil {
			lawyersListSubject?.onNext(())
		} else if let subIssueCode = issueType?.subIssueCode {
			self.selectedIssues = [subIssueCode]

			updateLayersListSubject = PublishSubject<Int>()
			updateLayersListSubject?
				.asObservable()
				.flatMap { [unowned self] subIssueCode in
					self.di.lawyersNetworkService.getLawyers(by: [subIssueCode],
															 city: currentCity?.title ?? "")
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
			updateLayersListSubject?.onNext(subIssueCode)
		}
	}

	private func update(with lawyers: [UserProfile]) {
		self.lawyers = lawyers
		let section = SectionModel<String, UserProfile>(model: "",
														items: lawyers)
		dataSourceSubject?.onNext([section])

		if lawyers.isEmpty {
			view.emptyLawyersLabel.isHidden = false
		} else {
			view.emptyLawyersLabel.isHidden = true
		}

		if self.view.tableView.contentSize.height + 100 < self.view.tableView.frame.height {
			self.view.tableView.isScrollEnabled = false
		} else {
			self.view.tableView.isScrollEnabled = true
		}
	}

	func removeBindings() {}
}
