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
		HasLocalStorageService &
		HasChatNetworkService
	lazy var di: Dependencies = DI.dependencies
	var messagesListSubject: PublishSubject<Any>?
	private var dataSourceSubject: BehaviorSubject<[SectionModel<String, ChatMessage>]>?

	init(chatConversation: ChatConversation) {
		self.chatConversation = chatConversation
	}

	func viewDidSet() {
		// table view data source
		let section = SectionModel<String, ChatMessage>(model: "",
														items: messages)
		dataSourceSubject = BehaviorSubject<[SectionModel]>(value: [section])
		dataSourceSubject?
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
		view.titleLabel.text = chatConversation.fullName

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

		//MARK: - Send message
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
														   headers: ["content-type": "application/json"])
					messagesListSubject?.onNext(())
				} catch {
					print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)

		//MARK: - Send data
		view.chatBarView.attachSubject
			.subscribe(onNext: { [weak self] text in
				guard let data = #imageLiteral(resourceName: "attach_button_icn").jpegData(compressionQuality: 0.5) else { return }

				self?.di.socketStompService.sendData(with: data,
													 to: "/chat/6/27/Анатолий/26/sendPhotoMessage",
													 receiptId: "",
													 headers: ["content-type": "multipart/form-data"])
				self?.messagesListSubject?.onNext(())
			}).disposed(by: disposeBag)

		messagesListSubject = PublishSubject<Any>()
		messagesListSubject?
			.asObservable()
			.flatMap { [unowned self] _ in
				self.di.chatNetworkService
					.getMessages(with: chatConversation.id)
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				self?.view.loadingView.stopAnimating()
				switch result {
					case .success(let messages):
						self?.update(with: messages)
					case .failure(let error):
						//TODO: - обработать ошибку
						print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)

		view.loadingView.startAnimating()

		//MARK: - incoming message
		di.socketStompService.incomingMessageSubject
			.asObservable()
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] _ in
				self?.messagesListSubject?.onNext(())
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

	private func update(with messages: [ChatMessage]) {
		self.messages = messages.sorted {
			$0.dateCreated < $1.dateCreated
		}
		let section = SectionModel<String, ChatMessage>(model: "",
														items: self.messages)
		dataSourceSubject?.onNext([section])
		scrollToBottom()

		if self.view.tableView.contentSize.height + 200 < self.view.tableView.frame.height {
			self.view.tableView.isScrollEnabled = false
		} else {
			self.view.tableView.isScrollEnabled = true
		}
	}

	func removeBindings() {}
}
