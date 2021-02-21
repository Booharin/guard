//
//  ChangePasswordViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 18.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ChangePasswordViewModel: ViewModel, HasDependencies {
	var view: ChangePasswordViewControllerProtocol!
	private let animationDuration = 0.15
	var clientProfile: UserProfile? {
		di.localStorageService.getCurrenClientProfile()
	}

	typealias Dependencies =
		HasAuthService &
		HasKeyChainService &
		HasLocalStorageService
	lazy var di: Dependencies = DI.dependencies

	private var disposeBag = DisposeBag()

	func viewDidSet() {
		// title
		view.titleLabel.font = SFUIDisplay.bold.of(size: 15)
		view.titleLabel.textColor = Colors.mainTextColor
		view.titleLabel.text = "change_password.title".localized

		// old password
		view.oldPasswordTextField.isSecureTextEntry = true
		view.oldPasswordTextField.configure(placeholderText: "change_password.old_password.title".localized)
		view.oldPasswordTextField
			.rx
			.text
			.subscribe(onNext: { [unowned self] _ in
				self.checkAreTextFieldsEmpty()
			}).disposed(by: disposeBag)

		// new password
		view.newPasswordTextField.isSecureTextEntry = true
		view.newPasswordTextField.configure(placeholderText: "change_password.new_password.title".localized)
		view.newPasswordTextField
			.rx
			.text
			.subscribe(onNext: { [unowned self] _ in
				self.checkAreTextFieldsEmpty()
			}).disposed(by: disposeBag)
		
		// alert label
		view.alertLabel.numberOfLines = 2
		view.alertLabel.textColor = Colors.warningColor
		view.alertLabel.textAlignment = .center
		view.alertLabel.font = SFUIDisplay.regular.of(size: 15)

		// swipe to go back
		view.view
			.rx
			.swipeGesture(.right)
			.when(.recognized)
			.subscribe(onNext: { [unowned self] _ in
				self.view.navController?.popViewController(animated: true)
			}).disposed(by: disposeBag)

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

		// MARK: - Check keyboard showing
		keyboardHeight()
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [unowned self] keyboardHeight in
				if keyboardHeight > 0 {
					self.turnWarnings()

					self.view.saveButton.snp.updateConstraints {
						$0.bottom.equalToSuperview().offset(-(keyboardHeight + 10))
					}
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.view.layoutIfNeeded()
					})
				} else {
					self.view.saveButton.snp.updateConstraints {
						$0.bottom.equalToSuperview().offset(-71)
					}
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.view.layoutIfNeeded()
					})
				}
			})
			.disposed(by: disposeBag)

		// save button
		view.saveButton.isEnabled = false
		view.saveButton
			.rx
			.tap
			.do(onNext: { [unowned self] _ in
				self.view.saveButton.animateBackground()
			})
			.filter { [unowned self] _ in
				if let oldPassword = self.di.keyChainService.getValue(for: Constants.KeyChainKeys.password),
				   self.view.oldPasswordTextField.text != oldPassword {
					self.turnWarnings(with: "change_password.oldPassword.error.title".localized)
					return false
				} else if self.view.newPasswordTextField.text?.count ?? 0 < 8 {
					self.turnWarnings(with: "registration.alert.password_too_short.title".localized.localized)
					return false
				} else {
					self.view.loadingView.play()
					return true
				}
			}
			.flatMap { [unowned self] credentials in
				self.di.authService.changePassword(id: clientProfile?.id ?? 0,
												   oldPassword: self.view.oldPasswordTextField.text ?? "",
												   newPassword: self.view.newPasswordTextField.text ?? "")
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				self?.view.loadingView.stop()
				switch result {
				case .success:
					self?.view.navController?.popViewController(animated: true)
				case .failure(let error):
					self?.turnWarnings(with: error.localizedDescription)
				}
			}).disposed(by: disposeBag)
	}

	private func checkAreTextFieldsEmpty() {
		guard
			let oldPasswordText = view.oldPasswordTextField.text,
			let newPasswordText = view.newPasswordTextField.text else { return }
		
		if !oldPasswordText.isEmpty && !newPasswordText.isEmpty {
			view.saveButton.isEnabled = true
			view.saveButton.backgroundColor = Colors.mainColor
		} else {
			view.saveButton.isEnabled = false
			view.saveButton.backgroundColor = Colors.buttonDisabledColor
		}
	}

	private func turnWarnings(with text: String? = nil) {
		if text == nil {
			guard
				let text = view.alertLabel.text,
				!text.isEmpty else { return }
			view.alertLabel.text = ""
		} else {
			view.view.endEditing(true)
			view.alertLabel.text = text
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
