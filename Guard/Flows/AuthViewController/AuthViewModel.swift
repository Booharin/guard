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

protocol AuthViewModelProtocol {
    
}

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
			self?.view.toMain?()
		}).disposed(by: disposeBag)
	}
	
	func keyboardHeight() -> Observable<CGFloat> {
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
