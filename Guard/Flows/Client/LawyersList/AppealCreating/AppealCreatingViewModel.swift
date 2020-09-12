//
//  AppealCreatingViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 12.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//
import UIKit
import RxSwift
import RxCocoa

final class AppealCreatingViewModel: ViewModel {
	var view: AppealCreatingViewControllerProtocol!
	private let animationDuration = 0.15
	private var disposeBag = DisposeBag()
	private let clientIssue: ClientIssue
	
	init(clientIssue: ClientIssue) {
		self.clientIssue = clientIssue
	}

	func viewDidSet() {
		// back button
		view.backButtonView
			.rx
			.tapGesture()
			.skip(1)
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

		// title
		view.titleLabel.font = Saira.regular.of(size: 18)
		view.titleLabel.textColor = Colors.mainTextColor
		view.titleLabel.text = "new_appeal.title".localized
		view.titleLabel.textAlignment = .center

		// subtitle
		view.subtitleLabel.font = Saira.light.of(size: 15)
		view.subtitleLabel.textColor = Colors.mainTextColor
		view.subtitleLabel.text = "new_appeal.subtitle.title".localized
		view.subtitleLabel.textAlignment = .center

		// login
		view.titleTextField.configure(placeholderText: "new_appeal.title.textfield.placeholder".localized)
		view.titleTextField
			.rx
			.text
			.subscribe(onNext: { _ in
				self.checkAreTextFieldsEmpty()
			}).disposed(by: disposeBag)

		// text view
		view.descriptionTextView.isEditable = true
		view.descriptionTextView.textColor = Colors.placeholderColor
		view.descriptionTextView.text = "new_appeal.textview.placeholder".localized
		view.descriptionTextView.font = Saira.light.of(size: 15)
		view.descriptionTextView.textAlignment = .center
		view.descriptionTextView
			.rx
			.text
			.subscribe(onNext: { [unowned self] _ in
				self.checkAreTextFieldsEmpty()
			}).disposed(by: disposeBag)

		// send button
		view.createAppealButton.isEnabled = false
		view.createAppealButton
			.rx
			.tap
			.do(onNext: { [unowned self] _ in
				self.view.createAppealButton.animateBackground()
			})
			.subscribe(onNext: { [unowned self] _ in
				self.view.navController?.popToRootViewController(animated: true)
			}).disposed(by: disposeBag)
	}
	
	private func checkAreTextFieldsEmpty() {

		guard
			let title = view.titleTextField.text,
			let description = view.descriptionTextView.text else { return }

		if !title.isEmpty,
			!description.isEmpty {
			view.createAppealButton.isEnabled = true
			view.createAppealButton.backgroundColor = Colors.greenColor
		} else {
			view.createAppealButton.isEnabled = false
			view.createAppealButton.backgroundColor = Colors.buttonDisabledColor
		}
	}
	
//	private func checkIsPlaceHolderNeeded(_ text: String?) {
//		guard let text = text else { return }
//		if text.isEmpty {
//			view.descriptionTextView.textColor = Colors.placeholderColor
//			view.descriptionTextView.font = Saira.light.of(size: 15)
//			view.descriptionTextView.text = "new_appeal.textview.placeholder".localized
//			view.descriptionTextView.textAlignment = .center
//		} else {
//			view.descriptionTextView.textColor = Colors.mainTextColor
//			view.descriptionTextView.font = SFUIDisplay.regular.of(size: 16)
//			view.descriptionTextView.text = nil
//			view.descriptionTextView.textAlignment = .natural
//		}
//	}

	func removeBindings() {}
}
