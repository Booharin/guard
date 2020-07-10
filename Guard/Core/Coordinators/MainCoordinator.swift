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
    
    override func start() {
        showMainModule()
    }
    
    private func showMainModule() {
        let controller = MainViewController()
        controller.coordinator = self
		
		//MARK: - Pass to CameraViewController
//		controller.toCameraViewController = { [weak controller] in
//			let descriptionController = CameraViewController()
//			controller?.navigationController?.pushViewController(descriptionController,
//																 animated: true)
//		}
        
        let rootController = NavigationController(rootViewController: controller)
        setAsRoot(rootController)
        self.rootController = rootController
    }
}
