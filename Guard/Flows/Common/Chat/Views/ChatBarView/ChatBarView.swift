//
//  ChatBarView.swift
//  Guard
//
//  Created by Alexandr Bukharin on 17.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol ChatBarViewProtocol: UIView {
	var sendSubject: PublishSubject<String> { get }
	var attachSubject: PublishSubject<Any> { get }
	var textViewChangeHeight: PublishSubject<CGFloat> { get }
	func clearMessageTextView()
}

final class ChatBarView: UIView, ChatBarViewProtocol {
	private let animationDuration = 0.15
	private var disposeBag = DisposeBag()

	private let messageTextView = UITextView()
	private let attachButton = UIButton()
	private let sendButton = UIButton()
	var sendSubject = PublishSubject<String>()
	var attachSubject = PublishSubject<Any>()
	var textViewChangeHeight = PublishSubject<CGFloat>()
	private var currentMessageViewHeight: CGFloat = 0

	init() {
		super.init(frame: .zero)
		setupViews()
		layoutViews()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupViews() {
		// attach button
		addSubview(attachButton)
		attachButton.backgroundColor = Colors.greenColor
		attachButton.layer.cornerRadius = 18
		attachButton.setImage(#imageLiteral(resourceName: "attach_button_icn"), for: .normal)
		attachButton.rx
			.tap
			.subscribe(onNext: { [weak self] _ in
				self?.attachSubject.onNext(())
			}).disposed(by: disposeBag)

		// send button
		addSubview(sendButton)
		sendButton.backgroundColor = Colors.mainColor
		sendButton.layer.cornerRadius = 18
		sendButton.setImage(#imageLiteral(resourceName: "send_button_icn"), for: .normal)
		sendButton.rx
			.tap
			.subscribe(onNext: { [weak self] _ in
				guard
					let text = self?.messageTextView.text,
					!text.isEmpty else { return }
				self?.sendSubject.onNext(text)
			}).disposed(by: disposeBag)

		addSubview(messageTextView)
		messageTextView.layer.cornerRadius = 18
		messageTextView.layer.borderColor = Colors.mainColor.cgColor
		messageTextView.layer.borderWidth = 1
		messageTextView.delegate = self
		messageTextView.isEditable = true
		messageTextView.textColor = Colors.placeholderColor
		messageTextView.text = "chat.placeholder".localized
		messageTextView.font = Saira.light.of(size: 15)
		messageTextView.contentInset = UIEdgeInsets(top: -2,
													left: 10,
													bottom: 2,
													right: 10)
		messageTextView.rx
			.text
			.subscribe(onNext: { [weak self] _ in
				guard
					let text = self?.messageTextView.text,
					!text.isEmpty else { return }
				let height = text.height(withConstrainedWidth: UIScreen.main.bounds.width - 180,
										 font: SFUIDisplay.regular.of(size: 16))
				guard height != self?.currentMessageViewHeight else { return }
				// claculate needed bar height
				if height > 36 {
					self?.textViewChangeHeight.onNext(106 + (height - 26))
				} else {
					self?.textViewChangeHeight.onNext(106)
				}
			}).disposed(by: disposeBag)
	}

	private func layoutViews() {
		attachButton.snp.makeConstraints {
			$0.leading.equalToSuperview().offset(25)
			$0.width.equalTo(44)
			$0.height.equalTo(36)
			$0.bottom.equalToSuperview().offset(-40)
		}

		sendButton.snp.makeConstraints {
			$0.trailing.equalToSuperview().offset(-25)
			$0.width.equalTo(44)
			$0.height.equalTo(36)
			$0.bottom.equalToSuperview().offset(-40)
		}

		messageTextView.snp.makeConstraints {
			$0.leading.equalTo(attachButton.snp.trailing).offset(6)
			$0.trailing.equalTo(sendButton.snp.leading).offset(-6)
			$0.bottom.equalToSuperview().offset(-40)
			$0.top.equalToSuperview().offset(30)
		}
	}

	func clearMessageTextView() {
		messageTextView.text = ""
	}
}

extension ChatBarView: UITextViewDelegate {
	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.textColor == Colors.placeholderColor {
			textView.text = nil
			textView.textColor = Colors.mainTextColor
			textView.font = SFUIDisplay.regular.of(size: 16)
			textView.contentInset = UIEdgeInsets(top: 0,
												 left: 10,
												 bottom: 0,
												 right: 10)
		}
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		if textView.text.isEmpty {
			textView.text = "chat.placeholder".localized
			textView.textColor = Colors.placeholderColor
			textView.font = Saira.light.of(size: 15)
			textView.contentInset = UIEdgeInsets(top: -2,
												 left: 10,
												 bottom: 2,
												 right: 10)
		}
	}
	
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
