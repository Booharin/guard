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
	private var router: LawyerListRouterProtocol

	private let cities = [
		"cities.moscow".localized
	]

	var lawyers = [UserProfile]()

	typealias Dependencies =
		HasLocationService &
		HasLocalStorageService &
		HasLawyersNetworkService
	lazy var di: Dependencies = DI.dependencies

	private var toLawyerSubject: PublishSubject<UserProfile>?
	private var dataSourceSubject: BehaviorSubject<[SectionModel<String, UserProfile>]>?

	init(router: LawyerListRouterProtocol) {
		self.router = router
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
			.subscribe(onNext: { _ in
				//
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
			// TODO: - когда будет понятно какой список городов вернется от сервера
			//view.titleLabel.text = "\(profile.city)"
		}
		view.titleLabel.text = "Москва"

		lawyersListSubject = PublishSubject<Any>()
		lawyersListSubject?
			.asObservable()
			.flatMap { [unowned self] _ in
				self.di.lawyersNetworkService.getAllLawyers(from: self.view.titleLabel.text ?? "")
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
		lawyersListSubject?.onNext(())
	}

	private func update(with lawyers: [UserProfile]) {
		self.lawyers = lawyers
		let section = SectionModel<String, UserProfile>(model: "",
														items: lawyers)
		dataSourceSubject?.onNext([section])

		if self.view.tableView.contentSize.height + 100 < self.view.tableView.frame.height {
			self.view.tableView.isScrollEnabled = false
		} else {
			self.view.tableView.isScrollEnabled = true
		}
	}

	func removeBindings() {}
}
