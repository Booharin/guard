//
//  ClientAppealsListModuleFactory.swift
//  Guard
//
//  Created by Alexandr Bukharin on 11.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

final class ClientAppealsListModuleFactory {
    static func createModule() -> NavigationController {
        let router = ClientAppealsListRouter()
        let viewModel = ClientAppealsListViewModel(router: router)
        let controller = NavigationController(rootViewController:
            ClientAppealsListViewController(viewModel: viewModel)
        )
        router.navigationController = controller
        return controller
    }
}
