//
//  ClientsListRouter.swift
//  Guard
//
//  Created by Alexandr Bukharin on 12.09.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import Foundation
import RxSwift

protocol ClientsListRouterProtocol {
    func passToClient(with userProfile: UserProfile)
}

final class ClientsListRouter: BaseRouter, ClientsListRouterProtocol {

    func passToClient(with userProfile: UserProfile) {
        let controller = ClientFromAppealModuleFactory.createModule(clientProfile: userProfile,
                                                                    navController: self.navigationController)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
