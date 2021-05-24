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

	typealias Dependencies =
        HasClientNetworkService &
        HasLocalStorageService
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

		view.avatarImageView.layer.cornerRadius = 21
		view.avatarImageView.clipsToBounds = true
		view.avatarImageView.layer.borderWidth = 1
		view.avatarImageView.layer.borderColor = Colors.lightGreyColor.cgColor

		if let image = self.di.localStorageService.getImage(with: "\(chatConversation.userId)_profile_image.jpeg") {
			view.avatarImageView.image = image
		} else {
			view.avatarImageView.image = #imageLiteral(resourceName: "profile_icn").withRenderingMode(.alwaysTemplate)
			view.avatarImageView.tintColor = Colors.lightGreyColor
		}

		// not read messages label
		view.notReadmessagesNumberLabel.layer.cornerRadius = 8
		view.notReadmessagesNumberLabel.clipsToBounds = true
		view.notReadmessagesNumberLabel.font = SFUIDisplay.bold.of(size: 12)
		view.notReadmessagesNumberLabel.textColor = Colors.whiteColor
		view.notReadmessagesNumberLabel.backgroundColor = Colors.notReadMessagesBackgroundColor
		view.notReadmessagesNumberLabel.textAlignment = .center
		view.notReadmessagesNumberLabel.isHidden = true
		view.numberMessagesLabel.isHidden = true

		if let notReadNumber = chatConversation.countNotReadMessage,
		   notReadNumber > 0 {
			if notReadNumber < 10 {
				view.notReadmessagesNumberLabel.text = "\(notReadNumber)"
			} else {
				view.notReadmessagesNumberLabel.text = "1.."
				view.notReadmessagesNumberLabel.font = SFUIDisplay.bold.of(size: 11)
			}

			view.notReadmessagesNumberLabel.isHidden = false
			view.numberMessagesLabel.isHidden = false
		}

		view.nameTitleLabel.text = chatConversation.fullName.count <= 1 ? "chat.noName".localized : chatConversation.fullName
		view.nameTitleLabel.font = SFUIDisplay.regular.of(size: 16)
		view.nameTitleLabel.textColor = Colors.mainTextColor

		view.lastMessageLabel.font = SFUIDisplay.light.of(size: 12)
		view.lastMessageLabel.textColor = Colors.subtitleColor
		view.lastMessageLabel.text = chatConversation.lastMessage

		view.dateLabel.font = SFUIDisplay.light.of(size: 10)
		view.dateLabel.textColor = Colors.mainTextColor
		view.dateLabel.text = Date.getCorrectDate(from: chatConversation.dateLastMessage ?? chatConversation.dateCreated,
												  format: "dd.MM.yyyy")

		view.timeLabel.font = SFUIDisplay.light.of(size: 10)
		view.timeLabel.textColor = Colors.mainTextColor
		view.timeLabel.text = Date.getCorrectDate(from: chatConversation.dateLastMessage ?? chatConversation.dateCreated,
												  format: "HH:mm")

		lawyerImageSubject
			.asObservable()
			.flatMap { [unowned self] _ in
				self.di.clientNetworkService.getPhoto(profileId: chatConversation.userId)
			}
			.subscribe(onNext: { [weak self] result in
				switch result {
				case .success(let data):
					self?.view.avatarImageView.image = UIImage(data: data)
					if let userID = self?.chatConversation.userId {
						self?.di.localStorageService.saveImage(data: data,
															   name: "\(userID)_profile_image.jpeg")
					}
				case .failure(let error):
					print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)
		lawyerImageSubject.onNext(())
	}
	func removeBindings() {}
}
