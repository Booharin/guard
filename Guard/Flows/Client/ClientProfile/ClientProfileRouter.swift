//
//  ClientProfileRouter.swift
//  Guard
//
//  Created by Alexandr Bukharin on 20.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxSwift

protocol ClientProfileRouterProtocol {
	var toSettingsSubject: PublishSubject<Any> { get }
}

final class ClientProfileRouter: BaseRouter, ClientProfileRouterProtocol {
	var toSettingsSubject = PublishSubject<Any>()
	private var disposeBag = DisposeBag()

	override init() {
		super.init()
		createTransitions()
	}
	
	private func createTransitions() {
		// to settings
		toSettingsSubject
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [unowned self] _ in
				self.passageToSettings()
			})
			.disposed(by: disposeBag)
	}
	
	private func passageToSettings() {
		let settingsController = SettingsViewController(viewModel: SettingsViewModel(userType: .client))
		settingsController.hidesBottomBarWhenPushed = true
		self.navigationController?.pushViewController(settingsController, animated: true)
	}
}
