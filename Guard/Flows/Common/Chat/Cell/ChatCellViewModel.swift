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

struct ChatCellViewModel: ViewModel {
	var view: ChatCellProtocol!
	private var disposeBag = DisposeBag()
    let animateDuration = 0.15
	let chatMessage: ChatMessage

	init(chatMessage: ChatMessage) {
		self.chatMessage = chatMessage
	}
	
	func viewDidSet() {
		// bubble
		view.bubbleView.clipsToBounds = true
		view.bubbleView.layer.cornerRadius = 13
		
		// message
		view.messageLabel.font = SFUIDisplay.regular.of(size: 15)
		view.messageLabel.textColor = Colors.mainTextColor
		view.messageLabel.text = chatMessage.text
		view.messageLabel.numberOfLines = 0
		
		// date
		view.dateLabel.font = SFUIDisplay.light.of(size: 10)
		view.dateLabel.textColor = Colors.mainTextColor
		view.dateLabel.text = Date.getString(with: chatMessage.dateCreated, format: "dd.MM.yyyy HH:mm")
		
		switch chatMessage.messageType {
		case .incoming:
			// bubble
			view.bubbleView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
			view.bubbleView.backgroundColor = Colors.incomingMessageBackground
			// message
			view.messageLabel.textAlignment = .left
		case .outgoing:
			// bubble
			view.bubbleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
			view.bubbleView.backgroundColor = Colors.outgoingMessageBackground
			// message
			view.messageLabel.textAlignment = .right
		}
	}
	
	func removeBindings() {}
}
