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

final class AppealCreatingViewModel: ViewModel, HasDependencies {
	var view: AppealCreatingViewControllerProtocol!
	private let animationDuration = 0.15
	private var disposeBag = DisposeBag()
	private let issueType: IssueType
	typealias Dependencies =
		HasLocalStorageService &
		HasAppealsNetworkService
	lazy var di: Dependencies = DI.dependencies

	init(issueType: IssueType) {
		self.issueType = issueType
	}

	func viewDidSet() {
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

		// client issue title
		view.issueTitleLabel.font = SFUIDisplay.medium.of(size: 15)
		view.issueTitleLabel.textColor = Colors.warningColor
		view.issueTitleLabel.numberOfLines = 2
		view.issueTitleLabel.textAlignment = .center
		view.issueTitleLabel.text = issueType.title

		// title
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
		view.descriptionTextView.backgroundColor = Colors.whiteColor
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
				self.view.loadingView.startAnimating()
			})
			.flatMap { [unowned self] _ in
				self.di.appealsNetworkService
					.createAppeal(title: self.view.titleTextField.text ?? "",
								  appealDescription: self.view.descriptionTextView.text ?? "",
								  clientId: self.di.localStorageService.getCurrenClientProfile()?.id ?? 0,
								  issueCode: issueType.issueCode,
								  cityCode: self.di.localStorageService.getCurrenClientProfile()?.cityCode?.first ?? 99)
			}
			.subscribe(onNext: { [weak self] result in
				self?.view.loadingView.stopAnimating()
				switch result {
				case .success:
					self?.view.navController?.popToRootViewController(animated: true)
				case .failure(let error):
					//TODO: - обработать ошибку
					print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)

		// MARK: - Check keyboard showing
		keyboardHeight()
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [unowned self] keyboardHeight in
				if keyboardHeight > 0 {
					guard self.view.descriptionTextView.textColor == Colors.mainTextColor else { return }
					self.view.descriptionTextView.contentInset = UIEdgeInsets(top: 0,
																			  left: 0,
																			  bottom: keyboardHeight,
																			  right: 0)
				} else {
					self.view.descriptionTextView.contentInset = UIEdgeInsets(top: 0,
																			  left: 0,
																			  bottom: 0,
																			  right: 0)
				}
			})
			.disposed(by: disposeBag)
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

	func removeBindings() {}
}
