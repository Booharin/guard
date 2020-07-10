//
//  AuthCoordinator.swift
//  Wheels
//
//  Created by Alexandr Bukharin on 23.06.2020.
//  Copyright © 2020 ds. All rights reserved.
//
import UIKit

final class AuthCoordinator: BaseCoordinator {
    
    var rootController: NavigationController?
    var onFinishFlow: (() -> Void)?
	private let userType: UserType
	
	init(userType: UserType) {
		self.userType = userType
	}
    
    override func start() {
        showLoginModule()
    }
    
    private func showLoginModule() {
        let controller = AuthViewController()
        
        controller.toMain = { [weak self] in
			UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKeys.isLogin)
            self?.toMain()
        }
        
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
}
