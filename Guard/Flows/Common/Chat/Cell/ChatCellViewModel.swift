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

	}
	
	func removeBindings() {}
}
