//
//  SettingsViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 23.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class SettingsViewModel: ViewModel, HasDependencies {
	var view: SettingsViewControllerProtocol!
	private let animationDuration = 0.15
	private var userRole: UserRole
	private var disposeBag = DisposeBag()

	private let logoutSubject: PublishSubject<Any>
	private let logoutWithAlertSubject = PublishSubject<Any>()
	private let changePasswordSubject = PublishSubject<Any>()
	private var settingsListSubject: PublishSubject<Any>?
	private var dataSourceSubject: BehaviorSubject<[SectionModel<String, SettingsCellType>]>?
	private let showLoaderSubject = PublishSubject<Bool>()

	typealias Dependencies =
		HasClientNetworkService &
		HasLocalStorageService
	lazy var di: Dependencies = DI.dependencies

	private var settingsCells = [SettingsCellType]()
	var clientProfile: UserProfile? {
		di.localStorageService.getCurrenClientProfile()
	}

	init(userRole: UserRole,
		 logoutSubject: PublishSubject<Any>) {
		self.userRole = userRole
		self.logoutSubject = logoutSubject
	}

	func viewDidSet() {
		// table view data source
		let section = SectionModel<String, SettingsCellType>(model: "",
															 items: settingsCells)
		dataSourceSubject = BehaviorSubject<[SectionModel]>(value: [section])
		dataSourceSubject?
			.bind(to: view.tableView
					.rx
					.items(dataSource: SettingsDataSource.dataSource()))
			.disposed(by: disposeBag)

		// title
		view.titleLabel.font = SFUIDisplay.bold.of(size: 15)
		view.titleLabel.textColor = Colors.mainTextColor
		view.titleLabel.text = "settings.title".localized

		// swipe to go back
		view.view
			.rx
			.swipeGesture(.right)
			.when(.recognized)
			.subscribe(onNext: { [unowned self] _ in
				self.view.navController?.popViewController(animated: true)
			}).disposed(by: disposeBag)

		// back button
		view.backButtonView
			.rx
			.tapGesture()
			.when(.recognized)
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.backButtonView.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.backButtonView.alpha = 1
					})
				})
			})
			.subscribe(onNext: { [weak self] _ in
				self?.view.navController?.popViewController(animated: true)
			}).disposed(by: disposeBag)

		changePasswordSubject
			.asObservable()
			.subscribe(onNext: { [weak self] _ in
				let changePasswordViewModel = ChangePasswordViewModel()
				let changePasswordViewController = ChangePasswordViewController(viewModel: changePasswordViewModel)
				self?.view.navController?.pushViewController(changePasswordViewController,
															 animated: true)
			}).disposed(by: disposeBag)

		logoutWithAlertSubject
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [unowned self] _ in
				self.view.showActionSheet(toAuthSubject: self.logoutSubject)
			})
			.disposed(by: disposeBag)

		showLoaderSubject
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] isShow in
				switch isShow {
				case true:
					self?.view.loadingView.startAnimating()
				case false:
					self?.view.loadingView.stopAnimating()
				}
			}).disposed(by: disposeBag)

		settingsListSubject = PublishSubject<Any>()
		settingsListSubject?
			.flatMap ({ _ -> Observable<Bool> in
				if let settings = self.di.localStorageService.getSettings(for: self.clientProfile?.id ?? 0) {
					self.update(with: settings)
					self.view.loadingView.stopAnimating()
					return .just(false)
				} else {
					return .just(true)
				}
			})
			.filter { result in
				return result == true
			}
			.asObservable()
			.flatMap { [unowned self] _ in
				self.di.clientNetworkService
					.getSettings(profileId: self.clientProfile?.id ?? 0)
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				self?.view.loadingView.stopAnimating()
				switch result {
					case .success(let settings):
						self?.update(with: settings)
					case .failure(let error):
						//TODO: - обработать ошибку
						print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)

		view.loadingView.startAnimating()
		settingsListSubject?.onNext(())
	}

	private func update(with settings: SettingsModel) {
		self.settingsCells = [
			.headerItem(title: "settings.visibility.title".localized),
			.notificationItem(title: "settings.visibility.phone".localized,
							  isOn: settings.isPhoneVisible,
							  isSeparatorHidden: false,
							  showLoaderSubject: showLoaderSubject),
			.notificationItem(title: "settings.visibility.mail".localized,
							  isOn: settings.isEmailVisible,
							  isSeparatorHidden: false,
							  showLoaderSubject: showLoaderSubject),
			.notificationItem(title: "settings.visibility.chat".localized,
							  isOn: settings.isChatEnabled,
							  isSeparatorHidden: true,
							  showLoaderSubject: showLoaderSubject),
			.headerItem(title: "settings.other.title".localized),
			.changePasswordItem(changePasswordSubject: changePasswordSubject),
			.logoutItem(logoutSubject: logoutWithAlertSubject)
		]
		let section = SectionModel<String, SettingsCellType>(model: "",
															 items: self.settingsCells)
		dataSourceSubject?.onNext([section])

		if self.view.tableView.contentSize.height + 100 < self.view.tableView.frame.height {
			self.view.tableView.isScrollEnabled = false
		} else {
			self.view.tableView.isScrollEnabled = true
		}
	}

	func removeBindings() {}
}
