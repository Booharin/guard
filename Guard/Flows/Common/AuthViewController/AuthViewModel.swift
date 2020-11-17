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

final class AuthViewModel: ViewModel,
	AuthViewModelProtocol,
	HasDependencies {

	typealias Dependencies =
		HasLocalStorageService &
		HasAuthService
	lazy var di: Dependencies = DI.dependencies

	var view: AuthViewControllerProtocol!
	private var disposeBag = DisposeBag()
	private let animationDuration = 0.15
	let authSubject = PublishSubject<Any>()
	let toMainSubject: PublishSubject<UserType>?
	let toChooseSubject: PublishSubject<Any>?
	let toForgotPasswordSubject: PublishSubject<Any>?
	
	var logoTopOffset: CGFloat {
		switch UIScreen.displayClass {
		case .iPhone8:
			return 10
		case .iPhoneX:
			return 41
		case .iPhone8Plus:
			return 41
		case .iPhone11ProMax:
			return 81
		}
	}

	var loginTextFieldOffset: CGFloat {
		switch UIScreen.displayClass {
		case .iPhone11ProMax:
			return 33
		case .iPhone8:
			return 5
		default: return 13
		}
	}

	init(toMainSubject: PublishSubject<UserType>? = nil,
		 toChooseSubject: PublishSubject<Any>? = nil,
		 toForgotPasswordSubject: PublishSubject<Any>? = nil) {
		self.toMainSubject = toMainSubject
		self.toChooseSubject = toChooseSubject
		self.toForgotPasswordSubject = toForgotPasswordSubject
	}
	
	func viewDidSet() {
		// logo
		view.logoTitleLabel.font = Saira.bold.of(size: 30)
		view.logoTitleLabel.textColor = Colors.mainTextColor
		view.logoTitleLabel.text = "registration.logo.title".localized.uppercased()
		
		view.logoSubtitleLabel.font = SFUIDisplay.regular.of(size: 14)
		view.logoSubtitleLabel.textColor = Colors.mainTextColor
		view.logoSubtitleLabel.text = "registration.logo.subtitle".localized
		
		// login
		view.loginTextField.keyboardType = .emailAddress
		view.loginTextField.configure(placeholderText: "registration.login.placeholder".localized)
		view.loginTextField
			.rx
			.text
			.subscribe(onNext: { _ in
				self.checkAreTextFieldsEmpty()
			}).disposed(by: disposeBag)
		
		if let profile = di.localStorageService.getCurrenClientProfile() {
			view.loginTextField.text = profile.email
		}
		
		// password
		view.passwordTextField.configure(placeholderText: "registration.password.placeholder".localized,
										 isSeparatorHidden: true)
		view.passwordTextField.isSecureTextEntry = true
		view.passwordTextField
			.rx
			.text
			.subscribe(onNext: { _ in
				self.checkAreTextFieldsEmpty()
			}).disposed(by: disposeBag)
		
		// registration button
		view.registrationButton.titleLabel?.adjustsFontSizeToFitWidth = true
		view.registrationButton
			.rx
			.tap
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.registrationButton.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.registrationButton.alpha = 1
					})
				})
			})
			.subscribe(onNext: { [weak self] _ in
				self?.toChooseSubject?.onNext(())
			}).disposed(by: disposeBag)
		
		// face id button
		view.faceIDButton
			.rx
			.tapGesture()
			.when(.recognized)
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
		
		// forget password
		view.forgetPasswordLabel.text = "auth.forget_password.title".localized
		view.forgetPasswordLabel.font = Saira.light.of(size: 12)
		view.forgetPasswordLabel.textColor = Colors.mainTextColor
		view.forgetPasswordLabel
			.rx
			.tapGesture()
			.when(.recognized)
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
				self?.toForgotPasswordSubject?.onNext(())
			}).disposed(by: disposeBag)
		
		// enter button
		view.enterButton.isEnabled = false
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
		
		// alert label
		view.alertLabel.numberOfLines = 2
		view.alertLabel.textColor = Colors.warningColor
		view.alertLabel.textAlignment = .center
		view.alertLabel.font = SFUIDisplay.regular.of(size: 15)
		
		// MARK: - Check keyboard showing
		keyboardHeight()
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [unowned self] keyboardHeight in
				if keyboardHeight > 0 {

					self.turnWarnings()

					self.view.logoImageView.snp.updateConstraints {
						$0.top.equalToSuperview().offset(self.logoTopOffset)
					}
					self.view.loginTextField.snp.makeConstraints {
						$0.top.equalTo(self.view.logoSubtitleLabel.snp.bottom).offset(self.loginTextFieldOffset)
					}
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.view.layoutIfNeeded()
					})
				} else {
					self.view.logoImageView.snp.updateConstraints {
						$0.top.equalToSuperview().offset(81)
					}
					self.view.loginTextField.snp.makeConstraints {
						$0.top.equalTo(self.view.logoSubtitleLabel.snp.bottom).offset(33)
					}
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.view.layoutIfNeeded()
					})
				}
			})
			.disposed(by: disposeBag)
		
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
				
				//if credentials.0.isValidEmail {
					self.view.loadingView.startAnimating()
					return true
//				} else {
//					self.turnWarnings(with: "auth.alert.uncorrect_email.title".localized)
//					return false
//				}
			}
			.flatMap { [unowned self] credentials in
				self.di.authService.signIn(email: credentials.0,
										   password: credentials.1)
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] _ in
				self?.view.loadingView.stopAnimating()
				
				//TODO: - когда заработает авторизации нужно будет проверять клиент/юрист по наличию поля issuType
				
				self?.toMainSubject?.onNext(.client)
			}).disposed(by: disposeBag)
	}
	
	//MARK: - Face id tapped
	private func authenticateTapped() {
		let context = LAContext()
		var error: NSError?
		
		if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
			let reason = "Authorization"
			
			context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
				[weak self] success, authenticationError in
				
				DispatchQueue.main.async {
					if success {
//						self?.view.loginTextField.text = "admin@admin.ru"
//						self?.view.passwordTextField.text = "12345"
						self?.toMainSubject?.onNext(.client)
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
	
	private func checkAreTextFieldsEmpty() {
		
		guard
			let loginText = view.loginTextField.text,
			let passwordText = view.passwordTextField.text else { return }
		
		if !loginText.isEmpty,
			!passwordText.isEmpty {
			
			view.enterButton.isEnabled = true
			view.enterButton.backgroundColor = Colors.greenColor
		} else {
			view.enterButton.isEnabled = false
			view.enterButton.backgroundColor = Colors.buttonDisabledColor
		}
	}
	
	private func turnWarnings(with text: String? = nil) {
		if text == nil {
			guard
				let text = view.alertLabel.text,
				!text.isEmpty else { return }
			view.alertLabel.text = ""
			
			view.loginTextField.textColor = Colors.mainTextColor
			view.passwordTextField.textColor = Colors.mainTextColor
		} else {
			view.view.endEditing(true)
			view.alertLabel.text = text
			
			view.loginTextField.textColor = Colors.warningColor
			view.passwordTextField.textColor = Colors.warningColor
		}
	}

	func removeBindings() {}
}
