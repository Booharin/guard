//
//  ClientsListModuleFactory.swift
//  Guard
//
//  Created by Alexandr Bukharin on 12.09.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import Foundation

final class ClientsListModuleFactory {
    static func createModule() -> NavigationController {
        let router = ClientsListRouter()
        let viewModel = ClientsListViewModel(router: router)
        let controller = NavigationController(rootViewController: ClientsListViewController(viewModel: viewModel))
        router.navigationController = controller
        return controller
    }
}
