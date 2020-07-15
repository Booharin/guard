//
//  RegistrationViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 14.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxSwift
import RxCocoa
import RxGesture

final class RegistrationViewModel: ViewModel {
	var view: RegistratioViewControllerProtocol!
	private let animationDuration = 0.15
	private let textFieldAnimationDuration = 0.05
	var registrationSubject: PublishSubject<Any>?
	private var disposeBag = DisposeBag()
	
	func viewDidSet() {
		// title
		view.titleLabel.text = "registration.title".localized
		view.titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
		view.titleLabel.textAlignment = .center
		view.titleLabel.textColor = Colors.whiteColor
		
		// login
		view.loginTextField.keyboardType = .emailAddress
		view.loginTextField.attributedPlaceholder = NSAttributedString(string: "registration.login.placeholder".localized,
																	   attributes: [NSAttributedString.Key.foregroundColor: Colors.placeholderColor])
		view.loginTextField.titleLabel.text = "registration.login.title".localized
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
		view.passwordTextField.attributedPlaceholder = NSAttributedString(string: "registration.password.placeholder".localized,
																		  attributes: [NSAttributedString.Key.foregroundColor: Colors.placeholderColor])
		view.passwordTextField.titleLabel.text = "registration.password.title".localized
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
		
		// confirmation password
		view.confirmationPasswordTextField.titleLabel.text = "registration.confirm_password.title".localized
		view.confirmationPasswordTextField.isSecureTextEntry = true
		view.confirmationPasswordTextField.attributedPlaceholder = NSAttributedString(string: "registration.confirm_password.placeholder".localized,
																		  attributes: [NSAttributedString.Key.foregroundColor: Colors.placeholderColor])
		view.confirmationPasswordTextField
				.rx
				.text
				.subscribe(onNext: { [unowned self] in
					guard let text = $0 else { return }
					self.view.confirmationPasswordTextField.alertLabel.text = ""
					if text.isEmpty {
						UIView.animate(withDuration: self.textFieldAnimationDuration, animations: {
							self.view.confirmationPasswordTextField.backgroundColor = Colors.textFieldEmptyBackground
						})
					} else {
						UIView.animate(withDuration: self.textFieldAnimationDuration, animations: {
							self.view.confirmationPasswordTextField.backgroundColor = Colors.textFieldBackground
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
			self.registerUser()
			self.registrationSubject?.onNext(())
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
					// scroll
					guard self.view.scrollView.contentSize.height > self.view.scrollView.frame.height else { return }
                    self.view.scrollView.setContentOffset(CGPoint(x: 0,
                                                                  y: max(self.view.scrollView.contentSize.height - self.view.scrollView.bounds.size.height, 0)),
                                                          animated: true)
				}
            })
            .disposed(by: disposeBag)
	}
	
	// MARK: - Login flow
    private func registerUser() {
		let credentials = Observable.combineLatest(
            view.loginTextField.rx.text,
            view.passwordTextField.rx.text,
			view.confirmationPasswordTextField.rx.text
        ).filter { (login, password, confirmedPassword) -> Bool in
            return true
        }
        .map { ($0?.withoutExtraSpaces ?? "", $1?.withoutExtraSpaces ?? "", $2?.withoutExtraSpaces ?? "") }
		
		registrationSubject = PublishSubject<Any>()
		
		registrationSubject?
		.asObservable()
		.withLatestFrom(credentials)
        .filter { [unowned self] credentials in
			switch credentials.0 {
			case let s where s.count == 0:
				self.view.loginTextField.alertLabel.text = "registration.alert.empty.title".localized
			case let s where s.isValidEmail == false:
				self.view.loginTextField.alertLabel.text = "registration.alert.uncorrect_email.title".localized
			default: break
			}
			
			switch credentials.1 {
			case let s where s.count == 0:
				self.view.passwordTextField.alertLabel.text = "registration.alert.empty.title".localized
			case let s where s.count < 8:
				self.view.passwordTextField.alertLabel.text = "registration.alert.password_too_short.title".localized
			default: break
			}
			
			switch credentials.2 {
			case let s where s.count == 0:
				self.view.confirmationPasswordTextField.alertLabel.text = "registration.alert.empty.title".localized
			case let s where s != credentials.1:
				self.view.confirmationPasswordTextField.alertLabel.text = "registration.alert.passwords_different.title".localized
			default: break
			}
			
			if self.view.loginTextField.alertLabel.text?.isEmpty ?? false &&
				self.view.passwordTextField.alertLabel.text?.isEmpty ?? false &&
				self.view.confirmationPasswordTextField.alertLabel.text?.isEmpty ?? false {
				return true
			} else {
				return false
			}
        }
		.observeOn(MainScheduler.instance)
		.subscribe(onNext: { [weak self] _ in
			self?.view.loadingView.stopAnimating()
			self?.view.toMain?()
			},onError:  { [weak self] error in
			
			#if DEBUG
			print(error.localizedDescription)
			#endif
			
			self?.view.loadingView.stopAnimating()
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
