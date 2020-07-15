//
//  RegistrationCoordinator.swift
//  Guard
//
//  Created by Alexandr Bukharin on 11.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

final class RegistrationCoordinator: BaseCoordinator {
    
    var rootController: NavigationController?
    var onFinishFlow: (() -> Void)?
	private let userType: UserType
	
	init(userType: UserType) {
		self.userType = userType
	}
    
    override func start() {
        showRegistrationModule()
    }
    
    private func showRegistrationModule() {
        let controller = RegistrationViewController(viewModel: RegistrationViewModel())
        
        controller.toMain = { [weak self] in
			//UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKeys.isLogin)
            self?.toMain()
        }
		
		controller.toAuth = { [weak self] in
            self?.toAuth()
        }
		
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
		let controller = AuthViewController(viewModel: AuthViewModel(),
											isFromRegistration: true)
        controller.toMain = { [weak self] in
            self?.toMain()
        }
		guard let navVC = UIApplication.shared.windows.first?.rootViewController as? NavigationController else { return }
		navVC.pushViewController(controller, animated: true)
	}
}
