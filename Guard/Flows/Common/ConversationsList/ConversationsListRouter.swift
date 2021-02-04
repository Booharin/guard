//
//  ConversationsListRouter.swift
//  Guard
//
//  Created by Alexandr Bukharin on 15.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxSwift
import RxCocoa

protocol ConversationsListRouterProtocol {
	var toChatSubject: PublishSubject<ChatConversation> { get }
}

final class ConversationsListRouter: BaseRouter, ConversationsListRouterProtocol {

	var toChatSubject = PublishSubject<ChatConversation>()
	private var disposeBag = DisposeBag()

	override init() {
		super.init()
		createTransitions()
	}

	private func createTransitions() {
		// to chat
        toChatSubject
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { [unowned self] conversation in
			self.toChat(with: conversation)
        })
        .disposed(by: disposeBag)
	}

	private func toChat(with conversation: ChatConversation) {
		let router = ChatRouter()
		router.navigationController = navigationController
		let chatViewController = ChatViewController(viewModel: ChatViewModel(chatConversation: conversation,
																			 router: router))
		chatViewController.hidesBottomBarWhenPushed = true

		self.navigationController?.pushViewController(chatViewController, animated: true)
	}
}
