//
//  ChatCellViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 15.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

class ChatCellViewModel: ViewModel, HasDependencies {
	var view: ChatCellProtocol!
	private var disposeBag = DisposeBag()
	let animateDuration = 0.15
	let chatMessage: ChatMessage
	typealias Dependencies = HasLocalStorageService
	lazy var di: Dependencies = DI.dependencies

	init(chatMessage: ChatMessage) {
		self.chatMessage = chatMessage
	}

	func viewDidSet() {
		// bubble
		view.bubbleView.clipsToBounds = true
		view.bubbleView.layer.cornerRadius = 13
		// message textview
		view.messageTextView.isEditable = false
		view.messageTextView.backgroundColor = .clear
		view.messageTextView.isScrollEnabled = false
		view.messageTextView.dataDetectorTypes = [
			.link,
			.address,
			.phoneNumber
		]

		// message
		view.messageTextView.font = SFUIDisplay.regular.of(size: 15)
		view.messageTextView.textColor = Colors.mainTextColor
		if chatMessage.content.count > 10000 {
			view.messageTextView.text = "chat.file".localized
		} else {
			view.messageTextView.text = chatMessage.content
		}

		// date
		view.dateLabel.font = SFUIDisplay.light.of(size: 10)
		view.dateLabel.textColor = Colors.mainTextColor
		view.dateLabel.text = Date.getCorrectDate(from: chatMessage.dateCreated, format: "dd.MM.yyyy HH:mm")

		switch chatMessage.senderId {
		// outgoing
		case di.localStorageService.getCurrenClientProfile()?.id ?? 0:
			// bubble
			view.bubbleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
			view.bubbleView.backgroundColor = Colors.outgoingMessageBackground
			// message
			view.messageTextView.textAlignment = .right
		// incoming
		default:
			// bubble
			view.bubbleView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
			view.bubbleView.backgroundColor = Colors.incomingMessageBackground
			// message
			view.messageTextView.textAlignment = .left
		}
	}

	func removeBindings() {}
}
