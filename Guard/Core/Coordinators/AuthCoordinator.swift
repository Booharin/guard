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
		// to main
		let toMainSubject = PublishSubject<UserRole>()
		toMainSubject
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [unowned self] in
				self.toMain($0)
				self.onFinishFlow?()
			})
			.disposed(by: disposeBag)
		// to registration
		let toChooseSubject = PublishSubject<Any>()
		toChooseSubject
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [unowned self] _ in
				self.toChoose()
				self.onFinishFlow?()
			})
			.disposed(by: disposeBag)
		// forgot password
		let toForgotPasswordSubject = PublishSubject<Any>()
		toForgotPasswordSubject
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { _ in
				let forgotController = ForgotPasswordViewController(viewModel: ForgotPasswordViewModel())
				guard let navVC = UIApplication.shared.windows.first?.rootViewController as? NavigationController else { return }
				navVC.pushViewController(forgotController, animated: true)
			})
			.disposed(by: disposeBag)
		
		let viewModel = AuthViewModel(toMainSubject: toMainSubject,
									  toChooseSubject: toChooseSubject,
									  toForgotPasswordSubject: toForgotPasswordSubject)
		let controller = AuthViewController(viewModel: viewModel)
		
		if let navVC = UIApplication.shared.windows.first?.rootViewController as? NavigationController {
			navVC.pushViewController(controller, animated: true)
		} else {
			let rootController = NavigationController(rootViewController: controller)
			setAsRoot(rootController)
			self.rootController = rootController
		}
	}
	
	private func toMain(_ userRole: UserRole) {
		let coordinator = MainCoordinator(userRole: userRole)
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
		}
		addDependency(coordinator)
		coordinator.start()
	}
}
