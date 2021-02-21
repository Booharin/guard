//
//  ApplicationCoordinator.swift
//  Wheels
//
//  Created by Alexandr Bukharin on 23.06.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Foundation
import RxSwift

final class ApplicationCoordinator: BaseCoordinator, HasDependencies {
	typealias Dependencies =
		HasCommonDataNetworkService &
		HasLocalStorageService
	lazy var di: Dependencies = DI.dependencies
	private var disposeBag = DisposeBag()
	
	override init() {
		super.init()

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(toAuth),
			name: NSNotification.Name(rawValue: Constants.NotificationKeys.logout),
			object: nil)
	}

	override func start() {
		getCommonData()

		if UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.isLogin) {
			self.toAuth()
		} else {
			self.toChoose()
		}
	}

	private func toChoose() {
		let coordinator = ChooseCoordinator()
		coordinator.onFinishFlow = { [weak self, weak coordinator] in
			self?.removeDependency(coordinator)
		}
		addDependency(coordinator)
		coordinator.start()
	}

	@objc private func toAuth() {
		let coordinator = AuthCoordinator()
		coordinator.onFinishFlow = { [weak self, weak coordinator] in
			self?.removeDependency(coordinator)
		}
		addDependency(coordinator)
		coordinator.start()
	}

	private func getCommonData() {
		di.commonDataNetworkService.getCountriesAndCities()
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { result in
				switch result {
				case .success(let countries):
					let russiaCountry = countries.filter { $0.countryCode == 7 }
					self.di.localStorageService.saveCities(russiaCountry.first?.cities ?? [])
				case .failure(let error):
					//TODO: - обработать ошибку
					print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)

		di.commonDataNetworkService.getIssueTypes(for: "ru_ru")
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { result in
				switch result {
				case .success(let issueTypes):
					#if DEBUG
					print(issueTypes)
					#endif
				case .failure(let error):
					//TODO: - обработать ошибку
					print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)
	}
}
