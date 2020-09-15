//
//  ChatViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 14.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxSwift
import RxCocoa

final class ChatViewModel: ViewModel {
	var view: ChatViewControllerProtocol!
	private var disposeBag = DisposeBag()
	private let chatConversation: ChatConversation
	
	init(chatConversation: ChatConversation) {
        self.chatConversation = chatConversation
    }
	
	func viewDidSet() {
		
	}
	
	func removeBindings() {
		
	}
}
