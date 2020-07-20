//
//  SelectIssueCoordinator.swift
//  Guard
//
//  Created by Alexandr Bukharin on 20.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//
import UIKit

final class SelectIssueCoordinator: BaseCoordinator {
	var onFinishFlow: (() -> Void)?
    
    override func start() {
        showSelectIssueModule()
    }
    
    private func showSelectIssueModule() {
        let controller = SelectIssueViewController(viewModel: SelectIssueViewModel())
        
		guard let navVC = UIApplication.shared.windows.first?.rootViewController as? NavigationController else { return }
		navVC.pushViewController(controller, animated: true)
    }
}
