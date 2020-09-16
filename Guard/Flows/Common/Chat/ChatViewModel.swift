//
//  ChatViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 14.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class ChatViewModel: ViewModel {
	var view: ChatViewControllerProtocol!
	private let animationDuration = 0.15
	private var disposeBag = DisposeBag()
	private let chatConversation: ChatConversation
	private var messages = [ChatMessage]()
	
	init(chatConversation: ChatConversation) {
        self.chatConversation = chatConversation
    }
	
	func viewDidSet() {
		getMessagesFromServer()

		// table view data source
		let section = SectionModel<String, ChatMessage>(model: "",
														items: messages)
        let items = BehaviorSubject<[SectionModel]>(value: [section])
        items
            .bind(to: view.tableView
                .rx
                .items(dataSource: ChatDataSource.dataSource()))
            .disposed(by: disposeBag)

		// back button
		view.backButtonView
			.rx
			.tapGesture()
			.skip(1)
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.backButtonView.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.backButtonView.alpha = 1
					})
				})
			})
			.subscribe(onNext: { [weak self] _ in
				self?.view.navController?.popViewController(animated: true)
			}).disposed(by: disposeBag)
		
		// appeal button
		view.appealButtonView
			.rx
			.tapGesture()
			.skip(1)
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.appealButtonView.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.appealButtonView.alpha = 1
					})
				})
			})
			.subscribe(onNext: { [weak self] _ in
				//
			}).disposed(by: disposeBag)
		
		// title
		view.titleLabel.font = SFUIDisplay.bold.of(size: 15)
		view.titleLabel.textColor = Colors.mainTextColor
		view.titleLabel.text = chatConversation.companion.fullName
		
		// swipe to go back
		view.view
			.rx
			.swipeGesture(.right)
			.skip(1)
			.subscribe(onNext: { [unowned self] _ in
				self.view.navController?.popViewController(animated: true)
			}).disposed(by: disposeBag)
	}
	
	private func getMessagesFromServer() {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: messagesArray,
                                                      options: .prettyPrinted)
            let messagesResponse = try JSONDecoder().decode([ChatMessage].self, from: jsonData)
            self.messages = messagesResponse
			self.view.updateTableView()
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
    }

	func removeBindings() {}
	
	private let messagesArray = [
        ["dateCreated": 1599719845.0,
        "text": "Да мне тоже похуй, если честно!",
        "conversationId": 1,
		"eventOwner": "incoming"],
		["dateCreated": 1600279290.0,
        "text": "Да и нахуй мне нужны такие ваши услуги!",
        "conversationId": 1,
		"eventOwner": "outgoing"],
		["dateCreated": 1600279290.0,
        "text": "Надоело всё, не можете у моей жены штаны вернуть, а они мне дороги!",
        "conversationId": 1,
		"eventOwner": "outgoing"],
		["dateCreated": 1600279289.0,
        "text": "Делаю, всё что могу, она их не отдает, говорит, что еще собака ваша на них рожала",
        "conversationId": 1,
		"eventOwner": "incoming"],
		["dateCreated": 1600279288.0,
        "text": "Думаете легко с ней общаться постоянно?",
        "conversationId": 1,
		"eventOwner": "incoming"],
		["dateCreated": 1600279287.0,
        "text": "Ну как продвигается?",
        "conversationId": 1,
		"eventOwner": "outgoing"],
		["dateCreated": 1600279287.0,
        "text": "Добрый день",
        "conversationId": 1,
		"eventOwner": "outgoing"]
    ]
}
