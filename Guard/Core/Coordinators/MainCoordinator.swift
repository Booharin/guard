//
//  MainCoordinator.swift
//  Wheels
//
//  Created by Alexandr Bukharin on 23.06.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

final class MainCoordinator: BaseCoordinator {
    
    var rootController: UINavigationController?
    var onFinishFlow: (() -> Void)?
	private let userType: UserType
	
	init(userType: UserType, clientIssue: ClientIssue? = nil) {
		self.userType = userType
	}
    
    override func start() {
        showMainModule()
    }
    
    private func showMainModule() {
        
		let tabBarController = TabBarController()
		
		switch userType {
		case .client:
			tabBarController.viewControllers = getClientControllers()
		case .lawyer:
			tabBarController.viewControllers = getLawyerControllers()
		}
		
		guard let navVC = UIApplication.shared.windows.first?.rootViewController as? NavigationController else { return }
		navVC.pushViewController(tabBarController, animated: true)
    }
	
	private func getClientControllers() -> [UIViewController] {
		let lawyersListViewModel = LawyersListViewModel()
		let lawyersListViewController = LawyerListViewController(viewModel: lawyersListViewModel)
		return [lawyersListViewController]
	}
	
	private func getLawyerControllers() -> [UIViewController] {
		return []
	}
}
