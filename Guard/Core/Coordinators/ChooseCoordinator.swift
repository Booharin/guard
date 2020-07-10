//
//  ChooseCoordinator.swift
//  Guard
//
//  Created by Alexandr Bukharin on 10.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

final class ChooseCoordinator: BaseCoordinator {
	var rootController: NavigationController?
	var onFinishFlow: (() -> Void)?
	
	override func start() {
		showChooseModule()
	}
	
	private func showChooseModule() {
		let controller = ChooseViewController()
		
		controller.toAuth = { [weak self] userType in
			//			UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKeys.isLogin)
			self?.toAuth(userType)
		}
		
		let rootController = NavigationController(rootViewController: controller)
		setAsRoot(rootController)
		self.rootController = rootController
	}
	
	private func toAuth(_ userType: UserType) {
		let coordinator = AuthCoordinator(userType: userType)
		coordinator.onFinishFlow = { [weak self, weak coordinator] in
			self?.removeDependency(coordinator)
			self?.start()
		}
		addDependency(coordinator)
		coordinator.start()
	}
}
