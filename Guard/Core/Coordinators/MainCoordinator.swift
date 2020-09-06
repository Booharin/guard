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
	private let tabBarController = TabBarController()
	
	private var tabBarImages: [UIImage] {
		switch userType {
		case .client:
			return [#imageLiteral(resourceName: "tab_list_icn"), #imageLiteral(resourceName: "tab_appeals_icn"), #imageLiteral(resourceName: "tab_chat_icn"), #imageLiteral(resourceName: "tab_profile_icn")]
		case .lawyer:
			return [#imageLiteral(resourceName: "tab_list_icn"), #imageLiteral(resourceName: "tab_chat_icn"), #imageLiteral(resourceName: "tab_profile_icn")]
		}
    }
	
	init(userType: UserType, clientIssue: ClientIssue? = nil) {
		self.userType = userType
	}
    
    override func start() {
        showMainModule()
    }
    
    private func showMainModule() {
		
		switch userType {
		case .client:
			setClientControllers()
		case .lawyer:
			setLawyerControllers()
		}
		
		tabBarController.tabBar.items?.enumerated().forEach {
            $0.element.tag = $0.offset
			$0.element.image = tabBarImages[$0.offset]
			$0.element.selectedImage = tabBarImages[$0.offset]
        }
		tabBarController.tabBar.tintColor = Colors.blackColor
		
		guard let navVC = UIApplication.shared.windows.first?.rootViewController as? NavigationController else { return }
		navVC.pushViewController(tabBarController, animated: true)
    }
	
	private func setClientControllers() {
		tabBarController.viewControllers = [
			NavigationController(rootViewController: LawyerListViewController(viewModel: LawyersListViewModel())),
			NavigationController(rootViewController: LawyerListViewController(viewModel: LawyersListViewModel())),
			NavigationController(rootViewController: LawyerListViewController(viewModel: LawyersListViewModel())),
			NavigationController(rootViewController: LawyerListViewController(viewModel: LawyersListViewModel()))
		]
	}
	
	private func setLawyerControllers() {
		tabBarController.viewControllers = [
			NavigationController(rootViewController: LawyerListViewController(viewModel: LawyersListViewModel())),
			NavigationController(rootViewController: LawyerListViewController(viewModel: LawyersListViewModel())),
			NavigationController(rootViewController: LawyerListViewController(viewModel: LawyersListViewModel()))
		]
	}
}
