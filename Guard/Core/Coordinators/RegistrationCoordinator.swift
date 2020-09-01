//
//  RegistrationCoordinator.swift
//  Guard
//
//  Created by Alexandr Bukharin on 11.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
import RxSwift

final class RegistrationCoordinator: BaseCoordinator {
    
    var rootController: NavigationController?
    var onFinishFlow: (() -> Void)?
	private let userType: UserType
	private var disposeBag = DisposeBag()
	
	init(userType: UserType) {
		self.userType = userType
	}
    
    override func start() {
        showRegistrationModule()
    }
    
    private func showRegistrationModule() {
		// to select issue
		let toSelectIssueSubject = PublishSubject<Any>()
		toSelectIssueSubject
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] _ in
				self?.toSelectIssue()
			})
			.disposed(by: disposeBag)
		// to auth
		let toAuthSubject = PublishSubject<Any>()
		toAuthSubject
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] _ in
				self?.toAuth()
			})
			.disposed(by: disposeBag)

		let registrationViewModel = RegistrationViewModel(toSelectIssueSubject: toSelectIssueSubject,
														  toAuthSubject: toAuthSubject)
        let controller = RegistrationViewController(viewModel: registrationViewModel)
		
		guard let navVC = UIApplication.shared.windows.first?.rootViewController as? NavigationController else { return }
		navVC.pushViewController(controller, animated: true)
    }
    
    private func toMain() {
        let coordinator = MainCoordinator()
        coordinator.onFinishFlow = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
            self?.start()
        }
        addDependency(coordinator)
        coordinator.start()
    }
	
	private func toAuth() {
		let toMainSubject = PublishSubject<Any>()
		toMainSubject
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] _ in
				self?.toMain()
			})
			.disposed(by: disposeBag)

		let viewModel = AuthViewModel(toMainSubject: toMainSubject)
        let controller = AuthViewController(viewModel: viewModel)

		guard let navVC = UIApplication.shared.windows.first?.rootViewController as? NavigationController else { return }
		navVC.pushViewController(controller, animated: true)
	}
	
	private func toSelectIssue() {
		let coordinator = SelectIssueCoordinator()
        coordinator.onFinishFlow = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
            self?.start()
        }
        addDependency(coordinator)
        coordinator.start()
	}
}
