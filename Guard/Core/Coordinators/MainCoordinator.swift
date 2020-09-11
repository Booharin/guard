//
//  MainCoordinator.swift
//  Wheels
//
//  Created by Alexandr Bukharin on 23.06.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
import RxSwift

final class MainCoordinator: BaseCoordinator {
    
    var rootController: UINavigationController?
    var onFinishFlow: (() -> Void)?
	private let userType: UserType
	private let tabBarController = TabBarController()
	private var disposeBag = DisposeBag()
	
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
            $0.element.imageInsets = UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0)
        }
		tabBarController.tabBar.tintColor = Colors.blackColor
		
		guard let navVC = UIApplication.shared.windows.first?.rootViewController as? NavigationController else { return }
		navVC.pushViewController(tabBarController, animated: true)
    }
	
	private func setClientControllers() {
		// to lawyer issue
		let toLawyerSubject = PublishSubject<UserProfile>()
		toLawyerSubject
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { _ in
				//
			})
			.disposed(by: disposeBag)

		tabBarController.viewControllers = [
            // lawyers list
			NavigationController(rootViewController:
				LawyersListViewController(viewModel:
					LawyersListViewModel(toLawyerSubject: toLawyerSubject)
				)
			),
            // client appeals list
            ClientAppealsListModuleFactory.createModule(),

			NavigationController(rootViewController:
				LawyersListViewController(viewModel:
					LawyersListViewModel(toLawyerSubject: toLawyerSubject)
				)
			),
			NavigationController(rootViewController:
				LawyersListViewController(viewModel:
					LawyersListViewModel(toLawyerSubject: toLawyerSubject)
				)
			)
		]
	}
	
	private func setLawyerControllers() {
		// to lawyer issue
		let toClientSubject = PublishSubject<UserProfile>()
		toClientSubject
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { _ in
				//
			})
			.disposed(by: disposeBag)

		tabBarController.viewControllers = [
			NavigationController(rootViewController:
				LawyersListViewController(viewModel:
					LawyersListViewModel(toLawyerSubject: toClientSubject)
				)
			),
			NavigationController(rootViewController:
				LawyersListViewController(viewModel:
					LawyersListViewModel(toLawyerSubject: toClientSubject)
				)
			),
			NavigationController(rootViewController:
				LawyersListViewController(viewModel:
					LawyersListViewModel(toLawyerSubject: toClientSubject)
				)
			)
		]
	}
}
