//
//  AuthCoordinator.swift
//  Wheels
//
//  Created by Alexandr Bukharin on 23.06.2020.
//  Copyright © 2020 ds. All rights reserved.
//
import UIKit
import RxSwift

final class AuthCoordinator: BaseCoordinator {
    
    var rootController: NavigationController?
    var onFinishFlow: (() -> Void)?
	private var disposeBag = DisposeBag()
    
    override func start() {
        showLoginModule()
    }

    private func showLoginModule() {
		
		let toMainSubject = PublishSubject<Any>()
		toMainSubject
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] _ in
				self?.toMain()
			})
			.disposed(by: disposeBag)

		let viewModel = AuthViewModel(toMainSubject: toMainSubject)
        let controller = AuthViewController(viewModel: viewModel)
		
		let rootController = NavigationController(rootViewController: controller)
		setAsRoot(rootController)
		self.rootController = rootController
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

	private func toChoose() {
		let coordinator = ChooseCoordinator()
        coordinator.onFinishFlow = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
            self?.start()
        }
        addDependency(coordinator)
        coordinator.start()
    }
}
