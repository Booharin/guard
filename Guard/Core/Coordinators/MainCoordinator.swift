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

	init(userType: UserType, issueType: IssueType? = nil) {
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
			if tabBarImages[$0.offset] == #imageLiteral(resourceName: "tab_chat_icn") {
				$0.element.imageInsets = UIEdgeInsets(top: 12, left: 0, bottom: -12, right: 0)
			} else {
				$0.element.imageInsets = UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0)
			}
		}
		tabBarController.tabBar.tintColor = Colors.blackColor
		
		guard let navVC = UIApplication.shared.windows.first?.rootViewController as? NavigationController else { return }
		navVC.pushViewController(tabBarController, animated: true)
	}
	
	private func setClientControllers() {
		// to lawyer issue
		let toLawyerSubject = PublishSubject<LawyerProfile>()
		toLawyerSubject
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { _ in
				//
			})
			.disposed(by: disposeBag)
		// to auth
		let toAuthSubject = PublishSubject<Any>()
		toAuthSubject
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { _ in
				self.toAuth()
				self.onFinishFlow?()
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
			// conversations list
			ConversationsListModuleFactory.createModule(),
			// client profile
			ClientProfileModuleFactory.createModule(toAuthSubject: toAuthSubject)
		]
	}
	
	private func setLawyerControllers() {
		// to lawyer issue
		let toClientSubject = PublishSubject<ClientProfile>()
		toClientSubject
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { _ in
				//
			})
			.disposed(by: disposeBag)
		// TODO: - Set to lawyers controllers
//		tabBarController.viewControllers = [
//			NavigationController(rootViewController:
//									LawyersListViewController(viewModel:
//																LawyersListViewModel(toLawyerSubject: toClientSubject)
//									)
//			),
//			NavigationController(rootViewController:
//									LawyersListViewController(viewModel:
//																LawyersListViewModel(toLawyerSubject: toClientSubject)
//									)
//			),
//			NavigationController(rootViewController:
//									LawyersListViewController(viewModel:
//																LawyersListViewModel(toLawyerSubject: toClientSubject)
//									)
//			)
		//]
	}

	private func toAuth() {
		let coordinator = AuthCoordinator()
		coordinator.onFinishFlow = { [weak self, weak coordinator] in
			self?.removeDependency(coordinator)
		}
		addDependency(coordinator)
		coordinator.start()
	}
}
