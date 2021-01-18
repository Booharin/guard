//
//  ForgotPasswordViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 02.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

protocol ForgotPasswordViewModelProtocol {}

final class ForgotPasswordViewModel:
	ViewModel,
	ForgotPasswordViewModelProtocol,
	HasDependencies {
	
	typealias Dependencies = HasAuthService
	lazy var di: Dependencies = DI.dependencies

	var view: ForgotPasswordViewControllerProtocol!
	private let animationDuration = 0.15
	private var disposeBag = DisposeBag()
	var sendPasswordSubject: PublishSubject<Any>?

	func viewDidSet() {
		// logo
		view.logoTitleLabel.font = Saira.bold.of(size: 30)
		view.logoTitleLabel.textColor = Colors.mainTextColor
		view.logoTitleLabel.text = "registration.logo.title".localized.uppercased()
		
		view.logoSubtitleLabel.font = SFUIDisplay.regular.of(size: 14)
		view.logoSubtitleLabel.textColor = Colors.mainTextColor
		view.logoSubtitleLabel.text = "registration.logo.subtitle".localized
		
		// alert label
		view.hintLabel.numberOfLines = 2
		view.hintLabel.textColor = Colors.mainTextColor
		view.hintLabel.textAlignment = .center
		view.hintLabel.font = SFUIDisplay.regular.of(size: 15)
		view.hintLabel.text = "forgot.password.hint.title".localized
		
		// login
		view.loginTextField.keyboardType = .emailAddress
		view.loginTextField.configure(placeholderText: "registration.login.placeholder".localized)
		view.loginTextField
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
		
		// send button
		view.sendButton.isEnabled = false
		view.sendButton
			.rx
			.tap
			.do(onNext: { [unowned self] _ in
				self.view.sendButton.animateBackground()
				self.view.loadingView.startAnimating()
			})
			.subscribe(onNext: { [unowned self] _ in
				if sendPasswordSubject == nil {
					self.sendPassword()
				}
				self.sendPasswordSubject?.onNext(())
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

					self.view.sendButton.snp.updateConstraints {
						$0.bottom.equalToSuperview().offset(-(keyboardHeight + 10))
					}
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.view.layoutIfNeeded()
					})
				} else {
					self.view.sendButton.snp.updateConstraints {
						$0.bottom.equalToSuperview().offset(-71)
					}
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.view.layoutIfNeeded()
					})
				}
			})
			.disposed(by: disposeBag)
		
		// swipe to go back
		view.view
			.rx
			.swipeGesture(.right)
			.when(.recognized)
			.subscribe(onNext: { [unowned self] _ in
				self.view.navController?.popViewController(animated: true)
			}).disposed(by: disposeBag)
	}
	
	private func checkAreTextFieldsEmpty() {
		guard let loginText = view.loginTextField.text else { return }
		
		if !loginText.isEmpty {
			view.sendButton.isEnabled = true
			view.sendButton.backgroundColor = Colors.mainColor
		} else {
			view.sendButton.isEnabled = false
			view.sendButton.backgroundColor = Colors.buttonDisabledColor
		}
	}
	
	private func turnWarnings(with text: String? = nil) {
		if text == nil {
			guard
				let text = view.alertLabel.text,
				!text.isEmpty else { return }
			view.alertLabel.text = ""
			
			view.loginTextField.textColor = Colors.mainTextColor
		} else {
			view.view.endEditing(true)
			view.alertLabel.text = text
			
			view.loginTextField.textColor = Colors.warningColor
		}
	}
	
	// MARK: - Login flow
	private func sendPassword() {
		sendPasswordSubject = PublishSubject<Any>()
		sendPasswordSubject?
			.asObservable()
			.withLatestFrom(view.loginTextField.rx.text.asObservable())
			.map {
				$0?.withoutExtraSpaces ?? ""
			}
			.filter { [unowned self] in
				if $0.isValidEmail {
					return true
				} else {
					self.turnWarnings(with: "forgot.password.alert.title".localized)
					return false
				}
			}
			.flatMap { [unowned self] email in
				self.di.authService.forgotPassword(email: email)
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				self?.view.loadingView.stopAnimating()
				switch result {
				case .success:
					self?.view.navController?.popViewController(animated: true)
				case .failure(let error):
					//TODO: - обработать ошибку
					print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)
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
