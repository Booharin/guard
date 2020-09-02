//
//  ApplicationCoordinator.swift
//  Wheels
//
//  Created by Alexandr Bukharin on 23.06.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Foundation

final class ApplicationCoordinator: BaseCoordinator {
	
	override func start() {
		//if UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.isLogin) {
		self.toAuth()
		//		} else {
		//			self.toChoose()
		//		}
	}
	
	private func toChoose() {
		let coordinator = ChooseCoordinator()
		coordinator.onFinishFlow = { [weak self, weak coordinator] in
			self?.removeDependency(coordinator)
			self?.start()
		}
		addDependency(coordinator)
		coordinator.start()
	}
	
	private func toAuth() {
		let coordinator = AuthCoordinator()
		coordinator.onFinishFlow = { [weak self, weak coordinator] in
			self?.removeDependency(coordinator)
			self?.start()
		}
		addDependency(coordinator)
		coordinator.start()
	}
}
