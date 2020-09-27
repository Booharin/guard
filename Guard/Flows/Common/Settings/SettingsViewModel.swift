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
	private var userType: UserType
	private var disposeBag = DisposeBag()
	private let logoutSubject: PublishSubject<Any>
	
	//let items =
	
	init(userType: UserType,
		 logoutSubject: PublishSubject<Any>) {
		self.userType = userType
		self.logoutSubject = logoutSubject
	}

	func viewDidSet() {
		BehaviorSubject<[SettingsTableViewSection]>(value: [
			.VisibilitySection(items: [
				.notificationItem(title: "", isOn: true, isSeparatorHidden: false),
				.notificationItem(title: "", isOn: true, isSeparatorHidden: false),
				.notificationItem(title: "", isOn: true, isSeparatorHidden: true)
			]),
			.LogoutSection(items: [
				.logoutItem(logoutSubject: logoutSubject)
			])
		])
		.bind(to: view.tableView.rx.items(dataSource: SettingsDataSource.dataSource()))
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
	}

	func removeBindings() {}
}
