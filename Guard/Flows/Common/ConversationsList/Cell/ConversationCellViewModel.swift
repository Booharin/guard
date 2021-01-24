//
//  ConversationCellViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 15.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct ConversationCellViewModel: ViewModel {
	var view: ConversationCellProtocol!
	private var disposeBag = DisposeBag()
	let animateDuration = 0.15
	let chatConversation: ChatConversation
	let toChat: PublishSubject<ChatConversation>
	let tapSubject = PublishSubject<Any>()

	init(chatConversation: ChatConversation, toChat: PublishSubject<ChatConversation>) {
		self.chatConversation = chatConversation
		self.toChat = toChat
	}

	func viewDidSet() {
		view.containerView
			.rx
			.tapGesture()
			.when(.recognized)
			.subscribe(onNext: { _ in
				UIView.animate(withDuration: self.animateDuration, animations: {
					self.view.containerView.backgroundColor = Colors.lightBlueColor
				}, completion: { _ in
					UIView.animate(withDuration: self.animateDuration, animations: {
						self.view.containerView.backgroundColor = .clear
					})
				})
				self.toChat.onNext(self.chatConversation)
			}).disposed(by: disposeBag)

		view.avatarImageView.image = #imageLiteral(resourceName: "lawyer_mock_icn")

		view.nameTitleLabel.text = chatConversation.fullName
		view.nameTitleLabel.font = SFUIDisplay.regular.of(size: 16)
		view.nameTitleLabel.textColor = Colors.mainTextColor

		view.lastMessageLabel.font = SFUIDisplay.light.of(size: 12)
		view.lastMessageLabel.textColor = Colors.subtitleColor
		view.lastMessageLabel.text = chatConversation.lastMessage

		view.dateLabel.font = SFUIDisplay.light.of(size: 10)
		view.dateLabel.textColor = Colors.mainTextColor
		view.dateLabel.text = Date.getCorrectDate(from: chatConversation.dateCreated, format: "dd.MM.yyyy")

		view.timeLabel.font = SFUIDisplay.light.of(size: 10)
		view.timeLabel.textColor = Colors.mainTextColor
		view.timeLabel.text = Date.getCorrectDate(from: chatConversation.dateCreated, format: "HH:mm")
	}
	func removeBindings() {}
}
