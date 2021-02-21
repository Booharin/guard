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

final class ConversationCellViewModel:
	ViewModel,
	HasDependencies {

	var view: ConversationCellProtocol!
	let animateDuration = 0.15
	let chatConversation: ChatConversation

	typealias Dependencies = HasClientNetworkService
	lazy var di: Dependencies = DI.dependencies

	let toChat: PublishSubject<ChatConversation>
	private let lawyerImageSubject = PublishSubject<Any>()
	let tapSubject = PublishSubject<Any>()

	private let disposeBag = DisposeBag()

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

		view.avatarImageView.image = #imageLiteral(resourceName: "profile_icn").withRenderingMode(.alwaysTemplate)
		view.avatarImageView.tintColor = Colors.lightGreyColor
		view.avatarImageView.layer.cornerRadius = 21
		view.avatarImageView.clipsToBounds = true

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

		lawyerImageSubject
			.asObservable()
			.flatMap { [unowned self] _ in
				self.di.clientNetworkService.getPhoto(profileId: chatConversation.userId)
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				switch result {
					case .success(let data):
						self?.view.avatarImageView.image = UIImage(data: data)
					case .failure(let error):
						print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)
		lawyerImageSubject.onNext(())
	}
	func removeBindings() {}
}
