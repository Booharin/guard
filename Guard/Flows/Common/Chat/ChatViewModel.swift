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

final class ChatViewModel: ViewModel, HasDependencies {
	var view: ChatViewControllerProtocol!
	private let animationDuration = 0.15
	private var disposeBag = DisposeBag()
	private let chatConversation: ChatConversation
	private var messages = [ChatMessage]()
	typealias Dependencies =
		HasNotificationService &
		HasSocketStompService &
		HasLocalStorageService
	lazy var di: Dependencies = DI.dependencies
	
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
			.when(.recognized)
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
			.when(.recognized)
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
		view.titleLabel.text = "Pary Mason"//chatConversation.companion.fullName
		
		// swipe to go back
		view.view
			.rx
			.swipeGesture(.right)
			.when(.recognized)
			.subscribe(onNext: { [unowned self] _ in
				self.view.navController?.popViewController(animated: true)
			}).disposed(by: disposeBag)
		
		// MARK: - Check keyboard showing
		keyboardHeight()
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [unowned self] keyboardHeight in
				if keyboardHeight > 0 {
					let offset = keyboardHeight - 20
					self.view.chatBarView.snp.updateConstraints {
						$0.bottom.equalToSuperview().offset(-offset)
					}
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.view.layoutIfNeeded()
						self.scrollToBottom()
					})
				} else {
					self.view.chatBarView.snp.updateConstraints {
						$0.bottom.equalToSuperview()
					}
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.view.layoutIfNeeded()
					})
				}
			})
			.disposed(by: disposeBag)

		view.chatBarView
			.textViewChangeHeight
			.subscribe(onNext: { [unowned self] height in
				guard height < 200 else { return }
				self.view.chatBarView.snp.updateConstraints {
					$0.height.equalTo(height)
				}
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.view.layoutIfNeeded()
				})
			}).disposed(by: disposeBag)

		view.chatBarView.sendSubject
			.subscribe(onNext: { [unowned self] text in
				let dict: [String: Any] = [
					"senderName": self.di.localStorageService.getCurrenClientProfile()?.firstName ?? "Name",
					"content": text,
					"senderId": self.di.localStorageService.getCurrenClientProfile()?.id ?? 0
				]
				do {
					let jsonData = try JSONSerialization.data(withJSONObject: dict,
															  options: .prettyPrinted)
					guard let jSONText = String(data: jsonData, encoding: .utf8) else { return }

					self.di.socketStompService.sendMessage(with: jSONText,
														   to: "/app/chat/6/27/sendMessage",
														   receiptId: "",
														   headers: nil)
				} catch {
					print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)
	}
	
	// MARK: - Scroll table view to bottom
	func scrollToBottom() {
		let indexPath = IndexPath(row: messages.count-1, section: 0)
		guard indexPath.row >= 0 else { return }
		self.view.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
	}
	
	private func keyboardHeight() -> Observable<CGFloat> {
		return Observable
			.from([
				NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
					.map { notification -> CGFloat in
						(notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
					},
				NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
					.map { _ -> CGFloat in
						0
					}
			])
			.merge()
	}
	
	private func getMessagesFromServer() {
		do {
			let jsonData = try JSONSerialization.data(withJSONObject: messagesArray,
													  options: .prettyPrinted)
			let messagesResponse = try JSONDecoder().decode([ChatMessage].self, from: jsonData)
			self.messages = messagesResponse
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
