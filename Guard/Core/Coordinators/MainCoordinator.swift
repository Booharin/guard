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
	private let userRole: UserRole
	private var issueType: IssueType?
	private let tabBarController = TabBarController()
	private var disposeBag = DisposeBag()

	private var tabBarImages: [UIImage] {
		switch userRole {
		case .client:
			return [#imageLiteral(resourceName: "tab_list_icn"), #imageLiteral(resourceName: "tab_appeals_icn"), #imageLiteral(resourceName: "tab_chat_icn"), #imageLiteral(resourceName: "tab_profile_icn")]
		case .lawyer:
			return [#imageLiteral(resourceName: "tab_list_icn"), #imageLiteral(resourceName: "tab_chat_icn"), #imageLiteral(resourceName: "tab_profile_icn")]
		case .admin:
			return [#imageLiteral(resourceName: "tab_list_icn"), #imageLiteral(resourceName: "tab_appeals_icn"), #imageLiteral(resourceName: "tab_chat_icn"), #imageLiteral(resourceName: "tab_profile_icn")]
		}
	}

	init(userRole: UserRole, issueType: IssueType? = nil) {
		self.userRole = userRole
		self.issueType = issueType
		super.init()
	}

	override func start() {
		showMainModule()
	}

	private func showMainModule() {
		
		switch userRole {
		case .client:
			setClientControllers()
		case .lawyer:
			setLawyerControllers()
		case .admin:
			setClientControllers()
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
		// to auth
		let toAuthSubject = PublishSubject<Any>()
		toAuthSubject
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { _ in
				self.toAuth()
				//self.onFinishFlow?()
			})
			.disposed(by: disposeBag)

		let toChatWithLawyer = PublishSubject<ChatConversation>()

		tabBarController.viewControllers = [
			// lawyers list
			LawyersListModuleFactory.createModule(issueType: issueType),
			// client appeals list
			ClientAppealsListModuleFactory.createModule(),
			// conversations list
			ConversationsListModuleFactory.createModule(toChatWithLawyer: toChatWithLawyer),
			// client profile
			ClientProfileModuleFactory.createModule(toAuthSubject: toAuthSubject)
		]
	}
	
	private func setLawyerControllers() {
		// to auth
		let toAuthSubject = PublishSubject<Any>()
		toAuthSubject
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { _ in
				self.toAuth()
				//self.onFinishFlow?()
			})
			.disposed(by: disposeBag)

		let toChatWithLawyer = PublishSubject<ChatConversation>()

		tabBarController.viewControllers = [
			// appeals list
			AppealsListModuleFactory.createModule(),
			// conversations list
			ConversationsListModuleFactory.createModule(toChatWithLawyer: toChatWithLawyer),
			// lawyer profile
			LawyerProfileModuleFactory.createModule(toAuthSubject: toAuthSubject)
		]
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
