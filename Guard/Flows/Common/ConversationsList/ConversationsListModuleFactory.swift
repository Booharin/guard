//
//  ConversationsListModuleFactory.swift
//  Guard
//
//  Created by Alexandr Bukharin on 15.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxSwift

final class ConversationsListModuleFactory {
	static func createModule(toChatWithLawyer: PublishSubject<ChatConversation>?) -> NavigationController {
		let router = ConversationsListRouter()
		let viewModel = ConversationsListViewModel(router: router,
												   toChatWithLawyer: toChatWithLawyer)
		let controller = NavigationController(rootViewController:
			ConversationsListViewController(viewModel: viewModel)
		)
		router.navigationController = controller
		return controller
	}
}
