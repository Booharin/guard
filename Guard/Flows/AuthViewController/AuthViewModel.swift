//
//  AuthViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 11.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import LocalAuthentication

protocol AuthViewModelProtocol {}

final class AuthViewModel: ViewModel, AuthViewModelProtocol {
	var view: AuthViewControllerProtocol!
	private var disposeBag = DisposeBag()
	private let animationDuration = 0.15
	private let textFieldAnimationDuration = 0.05
	let authSubject = PublishSubject<Any>()
	
	func viewDidSet() {
		
		// login
		view.loginTextField.keyboardType = .emailAddress
		view.loginTextField.attributedPlaceholder = NSAttributedString(string: "auth.login.placeholder".localized,
																  attributes: [NSAttributedString.Key.foregroundColor: Colors.placeholderColor])
		view.loginTextField
		.rx
		.text
		.subscribe(onNext: { [unowned self] in
			guard let text = $0 else { return }
			self.view.loginTextField.alertLabel.text = ""
			if text.isEmpty {
				UIView.animate(withDuration: self.textFieldAnimationDuration, animations: {
					self.view.loginTextField.backgroundColor = Colors.textFieldEmptyBackground
				})
			} else {
				UIView.animate(withDuration: self.textFieldAnimationDuration, animations: {
					self.view.loginTextField.backgroundColor = Colors.textFieldBackground
				})
			}
		}).disposed(by: disposeBag)

		// password
		view.passwordTextField.isSecureTextEntry = true
		view.passwordTextField.attributedPlaceholder = NSAttributedString(string: "auth.password.placeholder".localized,
																		  attributes: [NSAttributedString.Key.foregroundColor: Colors.placeholderColor])
		view.passwordTextField
				.rx
				.text
				.subscribe(onNext: { [unowned self] in
					guard let text = $0 else { return }
					self.view.passwordTextField.alertLabel.text = ""
					if text.isEmpty {
						UIView.animate(withDuration: self.textFieldAnimationDuration, animations: {
							self.view.passwordTextField.backgroundColor = Colors.textFieldEmptyBackground
						})
					} else {
						UIView.animate(withDuration: self.textFieldAnimationDuration, animations: {
							self.view.passwordTextField.backgroundColor = Colors.textFieldBackground
						})
					}
				}).disposed(by: disposeBag)
		
		// face id button
		view.faceIDButton.tintColor = Colors.placeholderColor
		view.faceIDButton
		.rx
		.tapGesture()
		.skip(1)
		.do(onNext: { [unowned self] _ in
			UIView.animate(withDuration: self.animationDuration, animations: {
				self.view.faceIDButton.alpha = 0.5
			}, completion: { _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.faceIDButton.alpha = 1
				})
			})
		})
		.subscribe(onNext: { [unowned self] _ in
			self.authenticateTapped()
		}).disposed(by: disposeBag)
		
		// registration
		view.registrationLabel.text = "auth.registration.title".localized
		view.registrationLabel.font = UIFont.systemFont(ofSize: 16)
		view.registrationLabel.textColor = Colors.placeholderColor
		view.registrationLabel
		.rx
		.tapGesture()
		.skip(1)
		.do(onNext: { [unowned self] _ in
			UIView.animate(withDuration: self.animationDuration, animations: {
				self.view.registrationLabel.alpha = 0.5
			}, completion: { _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.registrationLabel.alpha = 1
				})
			})
		})
		.subscribe(onNext: { [weak self] _ in
			// to registration
		}).disposed(by: disposeBag)
		
		// forget password
		view.forgetPasswordLabel.text = "auth.forget_password.title".localized
		view.forgetPasswordLabel.font = UIFont.systemFont(ofSize: 16)
		view.forgetPasswordLabel.textColor = Colors.placeholderColor
		view.forgetPasswordLabel
		.rx
		.tapGesture()
		.skip(1)
		.do(onNext: { [unowned self] _ in
			UIView.animate(withDuration: self.animationDuration, animations: {
				self.view.forgetPasswordLabel.alpha = 0.5
			}, completion: { _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.forgetPasswordLabel.alpha = 1
				})
			})
		})
		.subscribe(onNext: { [weak self] _ in
			// to forget password
		}).disposed(by: disposeBag)
		
		// enter button
		view.enterButton
		.rx
		.tap
		.do(onNext: { [unowned self] _ in
			self.view.enterButton.animateBackground()
		})
		.subscribe(onNext: { [unowned self] _ in
			self.loginUser()
			self.authSubject.onNext(())
		}).disposed(by: disposeBag)
		
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
		
		// check keyboard showing
        keyboardHeight()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] keyboardHeight in
                if keyboardHeight > 0 {
					self.view.enterButton.snp.updateConstraints() {
						$0.bottom.equalToSuperview().offset(-(keyboardHeight + 30))
					}
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.view.layoutIfNeeded()
					})
				} else {
					self.view.enterButton.snp.updateConstraints() {
						$0.bottom.equalToSuperview().offset(-30)
					}
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.view.layoutIfNeeded()
					})
				}
            })
            .disposed(by: disposeBag)
		
		//MARK: - Face id tapped
		authenticateTapped()
	}
	
	// MARK: - Login flow
    private func loginUser() {
		let credentials = Observable.combineLatest(
            view.loginTextField.rx.text,
            view.passwordTextField.rx.text
        ).filter { (login, password) -> Bool in
            return true
        }
        .map { ($0?.withoutExtraSpaces ?? "", $1?.withoutExtraSpaces ?? "") }
		
		authSubject
		.asObservable()
		.withLatestFrom(credentials)
        .filter { [unowned self] credentials in
            if credentials.0.count > 0 && credentials.1.count > 0 {
                if credentials.0.isValidEmail {
                    self.view.loadingView.startAnimating()
                    return true
                } else {
					self.view.loginTextField.alertLabel.text = "auth.alert.uncorrect_email.title".localized
                    return false
                }
            } else if credentials.0.count < 1 {
				self.view.loginTextField.alertLabel.text = "auth.alert.empty.title".localized
				if credentials.1.count < 1 {
					self.view.passwordTextField.alertLabel.text = "auth.alert.empty.title".localized
				}
                return false
			} else {
				self.view.passwordTextField.alertLabel.text = "auth.alert.empty.title".localized
				return false
			}
        }
		.observeOn(MainScheduler.instance)
		.subscribe(onNext: { [weak self] _ in
			self?.view.loadingView.stopAnimating()
			self?.view.toMain?()
		}).disposed(by: disposeBag)
	}
	
	private func authenticateTapped() {
		let context = LAContext()
		var error: NSError?

		if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
			let reason = "Authorization"

			context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
				[weak self] success, authenticationError in

				DispatchQueue.main.async {
					if success {
						self?.view.loginTextField.text = "admin@admin.ru"
						self?.view.passwordTextField.text = "12345"
						self?.view.toMain?()
					} else {
						// error
					}
				}
			}
		} else {
			// no biometry
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
