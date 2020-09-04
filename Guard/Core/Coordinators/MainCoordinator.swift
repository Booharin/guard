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
        return [#imageLiteral(resourceName: "tab_list_icn"), #imageLiteral(resourceName: "tab_appeals_icn"), #imageLiteral(resourceName: "tab_chat_icn"), #imageLiteral(resourceName: "tab_profile_icn")]
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
		
		guard let navVC = UIApplication.shared.windows.first?.rootViewController as? NavigationController else { return }
		navVC.pushViewController(tabBarController, animated: true)
    }
	
	private func setClientControllers() {
		tabBarController.viewControllers = [
			LawyerListViewController(viewModel: LawyersListViewModel()),
			LawyerListViewController(viewModel: LawyersListViewModel()),
			LawyerListViewController(viewModel: LawyersListViewModel()),
			LawyerListViewController(viewModel: LawyersListViewModel())
		]
		tabBarController.tabBar.items?.enumerated().forEach {
            $0.element.tag = $0.offset
			$0.element.image = tabBarImages[$0.offset]
				.withRenderingMode(.alwaysTemplate)
				.withTintColor(Colors.tabBarItemColor)
			$0.element.selectedImage = tabBarImages[$0.offset]
				.withRenderingMode(.alwaysTemplate)
				.withTintColor(Colors.mainColor)
            //$0.element.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -12, right: 0)
        }
	}
	
	private func setLawyerControllers(){
		
	}
}
