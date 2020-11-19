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

final class SettingsViewModel: ViewModel {
	var view: SettingsViewControllerProtocol!
	private let animationDuration = 0.15
	private var userRole: UserRole
	private var disposeBag = DisposeBag()
	private let logoutSubject: PublishSubject<Any>
	private let logoutWithAlertSubject = PublishSubject<Any>()

	init(userRole: UserRole,
		 logoutSubject: PublishSubject<Any>) {
		self.userRole = userRole
		self.logoutSubject = logoutSubject
	}

	func viewDidSet() {
		let settingsItems: [SettingsCellType] = [
			.headerItem(title: "settings.visibility.title".localized),
			.notificationItem(title: "settings.visibility.phone".localized,
							  isOn: false,
							  isSeparatorHidden: false),
			.notificationItem(title: "settings.visibility.mail".localized,
							  isOn: true,
							  isSeparatorHidden: false),
			.notificationItem(title: "settings.visibility.notifications".localized,
							  isOn: true,
							  isSeparatorHidden: true),
			.headerItem(title: "settings.other.title".localized),
			.logoutItem(logoutSubject: logoutWithAlertSubject)
		]
		// table view data source
		let section = SectionModel<String, SettingsCellType>(model: "",
												items: settingsItems)
		let items = BehaviorSubject<[SectionModel]>(value: [section])
		items
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

		logoutWithAlertSubject
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [unowned self] _ in
				self.view.showActionSheet(toAuthSubject: self.logoutSubject)
			})
			.disposed(by: disposeBag)
	}

	func removeBindings() {}
}
