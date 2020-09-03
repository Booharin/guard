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
				self?.onFinishFlow?()
			})
			.disposed(by: disposeBag)
		// to auth
		let toAuthSubject = PublishSubject<Any>()
		toAuthSubject
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] _ in
				self?.toAuth()
				self?.onFinishFlow?()
			})
			.disposed(by: disposeBag)

		let registrationViewModel = RegistrationViewModel(toSelectIssueSubject: toSelectIssueSubject,
														  toAuthSubject: toAuthSubject)
        let controller = RegistrationViewController(viewModel: registrationViewModel)
		
		guard let navVC = UIApplication.shared.windows.first?.rootViewController as? NavigationController else { return }
		navVC.pushViewController(controller, animated: true)
    }
    
	private func toMain(clientIssue: ClientIssue) {
		let coordinator = MainCoordinator(userType: userType, clientIssue: clientIssue)
        coordinator.onFinishFlow = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
            self?.start()
        }
        addDependency(coordinator)
        coordinator.start()
    }
	
	private func toAuth() {
		let coordinator = AuthCoordinator()
		coordinator.onFinishFlow = { [weak self, weak coordinator] in
			self?.removeDependency(coordinator)
		}
		addDependency(coordinator)
		coordinator.start()
	}
	
	private func toSelectIssue() {
		// to main
		let toMainSubject = PublishSubject<ClientIssue>()
		toMainSubject
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { clientIssue in
				self.toMain(clientIssue: clientIssue)
				self.onFinishFlow?()
			})
			.disposed(by: disposeBag)
		
		let controller = SelectIssueViewController(viewModel: SelectIssueViewModel(toMainSubject: toMainSubject))
        
		guard let navVC = UIApplication.shared.windows.first?.rootViewController as? NavigationController else { return }
		navVC.pushViewController(controller, animated: true)
	}
	
	deinit {
		print("\(String(describing: self)) deinited")
	}
}
