//
//  ApplicationCoordinator.swift
//  Wheels
//
//  Created by Alexandr Bukharin on 23.06.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

final class ApplicationCoordinator: BaseCoordinator, HasDependencies {
	typealias Dependencies =
		HasCommonDataNetworkService &
		HasLocalStorageService &
		HasAuthService &
		HasKeyChainService
	lazy var di: Dependencies = DI.dependencies
	private var disposeBag = DisposeBag()
	private var isAlreadyPassedtToAuth = false
	
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
		guard isAlreadyPassedtToAuth == false else { return }
		isAlreadyPassedtToAuth = true
		
		if di.localStorageService.getCurrenClientProfile()?.userRole == .client {
			
			let storyboard = UIStoryboard(name: "LaunchLoading",
										  bundle: nil)
			let viewController = storyboard.instantiateViewController(withIdentifier: "LaunchViewController")
			let rootController = NavigationController(rootViewController: viewController)
			setAsRoot(rootController)
			if let controller = viewController as? LaunchViewController {
				controller.loadingView.play()
			}

			self.di.authService.signInById(
				with: self.di.keyChainService.getValue(for: Constants.KeyChainKeys.clientId) ?? ""
			)
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				switch result {
				case .success(_):
					self?.toMainWithClient()
				case .failure(_):
					self?.toAuthorization()
				}
			}).disposed(by: disposeBag)
		} else {
			toAuthorization()
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
			self.isAlreadyPassedtToAuth = false
		}
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

	private func toMainWithClient() {
		let coordinator = MainCoordinator(userRole: .client)
		coordinator.onFinishFlow = { [weak self, weak coordinator] in
			self?.removeDependency(coordinator)
			self?.start()
		}
		addDependency(coordinator)
		coordinator.start()
	}

	private func toAuthorization() {
		let coordinator = AuthCoordinator()
		coordinator.onFinishFlow = { [weak self, weak coordinator] in
			self?.removeDependency(coordinator)
		}
		addDependency(coordinator)
		coordinator.start()
	}
}
