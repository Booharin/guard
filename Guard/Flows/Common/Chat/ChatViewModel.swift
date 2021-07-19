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
	private var chatConversation: ChatConversation
	private var messages = [ChatMessage]()
	private let router: ChatRouterProtocol
	private let updateConversationSubject: PublishSubject<ChatConversation>

	typealias Dependencies =
		HasNotificationService &
		HasSocketStompService &
		HasLocalStorageService &
		HasChatNetworkService &
		HasAppealsNetworkService &
		HasLawyersNetworkService
	lazy var di: Dependencies = DI.dependencies

	var messagesListSubject: PublishSubject<Any>?
	private var dataSourceSubject: BehaviorSubject<[SectionModel<String, ChatMessage>]>?
	private let createConversationSubject = PublishSubject<Any>()
	private let createConversationByAppealSubject = PublishSubject<Any>()
	private let profileByIdSubject = PublishSubject<Int>()
	private var messageForSending: String?

	var imageForSending: Data?
	private var currentProfile: UserProfile? {
		di.localStorageService.getCurrenClientProfile()
	}

	init(chatConversation: ChatConversation,
		 updateConversationSubject: PublishSubject<ChatConversation>,
		 router: ChatRouterProtocol) {
		self.chatConversation = chatConversation
		self.updateConversationSubject = updateConversationSubject
		self.router = router
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
			.filter { _ in
				if self.chatConversation.appealId == nil {
					return false
				} else {
					return true
				}
			}
			.flatMap { [unowned self] _ in
				self.di.appealsNetworkService.getAppeal(by: self.chatConversation.appealId ?? 0)
			}
			.subscribe(onNext: { [weak self] result in
				self?.view.loadingView.stop()
				switch result {
					case .success(let appeal):
						self?.router.passageToAppealDescription(appeal: appeal)
					case .failure(let error):
						//TODO: - обработать ошибку
						print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)

		// MARK: - if appeal id nil appeal button hidden
		view.appealButtonView.isHidden = chatConversation.appealId == nil

		// title
		view.titleLabel.font = SFUIDisplay.bold.of(size: 15)
		view.titleLabel.textColor = Colors.mainTextColor
		view.titleLabel.text = chatConversation.fullName.count <= 1 ? "chat.noName".localized : chatConversation.fullName
		view.titleLabel
			.rx
			.tapGesture()
			.when(.recognized)
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.titleLabel.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.titleLabel.alpha = 1
					})
				})
			})
			.subscribe(onNext: { [weak self] _ in
				self?.profileByIdSubject.onNext(self?.chatConversation.userId ?? 0)
			}).disposed(by: disposeBag)

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
				// if new conversation need to create
				if chatConversation.id == -1 {
					self.messageForSending = text

					if chatConversation.appealId == nil {
						self.createConversationSubject.onNext(())
					} else {
						self.createConversationByAppealSubject.onNext(())
					}
				} else {
					self.sendMessage(with: text)
				}
			}).disposed(by: disposeBag)

		//MARK: - Send data
		view.chatBarView.attachSubject
			.subscribe(onNext: { [weak self] _ in
//				guard let self = self else { return }
//				guard let imageData = self.imageForSending else {
//					self.view.takePhotoFromGallery()
//					return
//				}
//
//				let path = "/app/chat/\(self.chatConversation.id)/\(self.chatConversation.userId)/\(self.currentProfile?.firstName ?? "Sender")/\(self.currentProfile?.id ?? 0)/sendPhotoMessageCheck"
//				self.di.socketStompService.sendData(with: imageData,
//													to: path,
//													receiptId: "",
//													headers: ["content-type": "application/json"])
//				self.imageForSending = nil
//				self.messagesListSubject?.onNext(())
				
				
///////////////////////////////////////////////////////////////---------------------------------------------------
				guard let self = self else { return }
				guard let imageData = self.imageForSending else {
					self.view.takePhotoFromGallery()
					return
				}
				let strBase64 = imageData.base64EncodedString()

				let dict: [String: Any] = [
					"senderName": self.di.localStorageService.getCurrenClientProfile()?.firstName ?? "Name",
					"content": "test content",
					"senderId": self.di.localStorageService.getCurrenClientProfile()?.id ?? 0,
					"fileName": "test.jpg",
					"fileBase64": strBase64
				]
				do {
					let jsonData = try JSONSerialization.data(withJSONObject: dict,
															  options: .prettyPrinted)
					guard let jSONText = String(data: jsonData, encoding: .utf8) else { return }

					let path =
						"""
						/app/chat/\(self.chatConversation.id)/\(self.chatConversation.userId)/sendMessage
						"""

					self.di.socketStompService.sendMessage(with: jSONText,
														   to: path,
														   receiptId: "",
														   headers: ["content-type": "application/json"])
					self.imageForSending = nil
					self.messagesListSubject?.onNext(())
					self.chatConversation.updateLastMessage(with: "chat.file".localized)
				} catch {
					print(error.localizedDescription)
				}
				self.messagesListSubject?.onNext(())
				self.updateConversationSubject.onNext(self.chatConversation)
			}).disposed(by: disposeBag)

		messagesListSubject = PublishSubject<Any>()
		messagesListSubject?
			.asObservable()
			.flatMap { [unowned self] _ in
				self.di.chatNetworkService
					.setMessagesRead(conversationId: chatConversation.id)
			}
			.flatMap { [unowned self] _ in
				self.di.chatNetworkService
					.getMessages(with: chatConversation.id)
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				self?.view.loadingView.stop()
				switch result {
					case .success(let messages):
						self?.update(with: messages)
					case .failure(let error):
						//TODO: - обработать ошибку
						print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)

		view.loadingView.play()

		//MARK: - incoming message
		di.socketStompService.incomingMessageSubject
			.asObservable()
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] _ in
				self?.messagesListSubject?.onNext(())
			}).disposed(by: disposeBag)

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(updateMessages),
			name: NSNotification.Name(rawValue: Constants.NotificationKeys.updateMessages),
			object: nil)

		// MARK: - Create conversation (client create)
		createConversationSubject
			.asObservable()
			.do(onNext: { _ in
				self.view.loadingView.play()
			})
			.flatMap { [unowned self] _ in
				self.di.chatNetworkService
					.createConversation(lawyerId: self.chatConversation.userId,
										clientId: currentProfile?.id ?? 0)
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				self?.view.loadingView.stop()
				switch result {
				case .success(let conversation):
					self?.chatConversation = conversation
					self?.sendMessage(with: self?.messageForSending ?? "")
				case .failure(let error):
					//TODO: - обработать ошибку
					print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)

		// MARK: - Create conversation by appeal (lawyer create)
		createConversationByAppealSubject
			.asObservable()
			.do(onNext: { _ in
				self.view.loadingView.play()
			})
			.flatMap { [unowned self] _ in
				self.di.chatNetworkService
					.createConversationByAppeal(lawyerId: currentProfile?.id ?? 0,
												clientId: self.chatConversation.userId,
												appealId: self.chatConversation.appealId ?? 0)
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				self?.view.loadingView.stop()
				switch result {
				case .success(let conversation):
					self?.chatConversation = conversation
					self?.sendMessage(with: self?.messageForSending ?? "")
				case .failure(let error):
					//TODO: - обработать ошибку
					print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)

		// MARK: - Geting profile by id
		profileByIdSubject
			.asObservable()
			.do(onNext: { _ in
				self.view.loadingView.play()
			})
			.flatMap { [unowned self] profileId in
				self.di.lawyersNetworkService.getLawyer(by: profileId)
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				self?.view.loadingView.stop()
				switch result {
				case .success(let profile):
					if profile.userRole == .lawyer {
						self?.router.passageToLawyer(with: profile)
					} else {
						self?.router.passageToClientProfile(with: profile)
					}
					print(profile)
				case .failure(let error):
					//TODO: - обработать ошибку
					print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)
	}

	private func sendMessage(with text: String) {
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
												   to: "/app/chat/\(chatConversation.id)/\(chatConversation.userId)/sendMessage",
												   receiptId: "",
												   headers: ["content-type": "application/json"])
			self.view.chatBarView.clearMessageTextView()
			self.view.loadingView.play()
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
				self.messagesListSubject?.onNext(())
			}
			self.chatConversation.updateLastMessage(with: text)
			self.updateConversationSubject.onNext(self.chatConversation)
		} catch {
			print(error.localizedDescription)
		}
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

	@objc private func updateMessages() {
		messagesListSubject?.onNext(())
	}

	func removeBindings() {}
}
