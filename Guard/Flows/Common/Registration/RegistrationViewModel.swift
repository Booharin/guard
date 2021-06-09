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
import MyTrackerSDK

final class RegistrationViewModel: ViewModel, HasDependencies {
	var view: RegistratioViewControllerProtocol!
	private let animationDuration = 0.15
	var registrationSubject: PublishSubject<Any>?
	private var disposeBag = DisposeBag()
	private let userRole: UserRole

	typealias Dependencies =
		HasLocalStorageService &
		HasRegistrationService &
		HasAuthService &
		HasKeyChainService
	lazy var di: Dependencies = DI.dependencies

	private var lawyerProfile: UserProfile? {
		return di.localStorageService.getCurrenClientProfile()
	}

	var logoTopOffset: CGFloat {
		switch UIScreen.displayClass {
		case .iPhone8, .iPhoneX:
			return -45
		case .iPhone8Plus:
			return -20
		case .iPhone11ProMax:
			return 0
		}
	}

	var logoSubtitleOffset: CGFloat {
		switch UIScreen.displayClass {
		case .iPhone11ProMax:
			return 30
		case .iPhone8:
			return -2
		default: return 15
		}
	}

	var logoTitleOffset: CGFloat {
		switch UIScreen.displayClass {
		case .iPhone11ProMax:
			return 8
		case .iPhone8:
			return -7
		default: return 0
		}
	}

	private var currentKeyboardHeight: CGFloat = 0

	let toSelectIssueSubject: PublishSubject<Any>?
	let toAuthSubject: PublishSubject<Any>?

	init(toSelectIssueSubject: PublishSubject<Any>? = nil,
		 toAuthSubject: PublishSubject<Any>? = nil,
		 userRole: UserRole) {
		self.toSelectIssueSubject = toSelectIssueSubject
		self.toAuthSubject = toAuthSubject
		self.userRole = userRole
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
		view.loginTextField.autocapitalizationType = .none
		view.loginTextField.configure(placeholderText: "registration.login.placeholder".localized)
		view.loginTextField
			.rx
			.text
			.subscribe(onNext: { [unowned self] _ in
				self.checkAreTextFieldsEmpty()
			}).disposed(by: disposeBag)

		// password
		view.passwordTextField.configure(placeholderText: "registration.password.placeholder".localized)
		view.passwordTextField.isSecureTextEntry = true
		view.passwordTextField.disableAutoFill()
		view.passwordTextField
			.rx
			.text
			.subscribe(onNext: { [unowned self] _ in
				self.checkAreTextFieldsEmpty()
			}).disposed(by: disposeBag)

		// confirmation password
		view.confirmationPasswordTextField.configure(placeholderText: "registration.confirm_password.placeholder".localized)
		view.confirmationPasswordTextField.isSecureTextEntry = true
		view.confirmationPasswordTextField.disableAutoFill()
		view.confirmationPasswordTextField
			.rx
			.text
			.subscribe(onNext: { [unowned self] _ in
				self.checkAreTextFieldsEmpty()
			}).disposed(by: disposeBag)

		//city
		view.cityTextField.configure(placeholderText: "registration.city.placeholder".localized,
									 isSeparatorHidden: true)
		view.cityTextField
			.rx
			.text
			.subscribe(onNext: { [unowned self] _ in
				self.checkAreTextFieldsEmpty()
			}).disposed(by: disposeBag)
		// TODO: - change when added city choosing
		view.cityTextField.text = "Москва"
		view.cityTextField.isEnabled = false

		// alert label
		view.alertLabel.numberOfLines = 2
		view.alertLabel.textColor = Colors.warningColor
		view.alertLabel.textAlignment = .center
		view.alertLabel.font = SFUIDisplay.regular.of(size: 15)

		// MARK: - Buttons

		// enter button
		view.enterButton.isEnabled = false
		view.enterButton
			.rx
			.tap
			.do(onNext: { [unowned self] _ in
				self.view.enterButton.animateBackground()
			})
			.subscribe(onNext: { [unowned self] _ in
				if registrationSubject == nil {
					self.registerUser()
				}
				self.view.loadingView.play()
				self.registrationSubject?.onNext(())
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

		// skip button
		view.skipButton
			.rx
			.tapGesture()
			.when(.recognized)
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.skipButton.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.skipButton.alpha = 1
					})
				})
			})
			.subscribe(onNext: { [weak self] _ in
				self?.toSelectIssueSubject?.onNext(())
			}).disposed(by: disposeBag)

		// already registered button
		view.alreadyRegisteredLabel.text = "registration.already_registered.title".localized
		view.alreadyRegisteredLabel.font = Saira.light.of(size: 12)
		view.alreadyRegisteredLabel.textAlignment = .center
		view.alreadyRegisteredLabel.textColor = Colors.mainTextColor
		view.alreadyRegisteredLabel
			.rx
			.tapGesture()
			.when(.recognized)
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.alreadyRegisteredLabel.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.alreadyRegisteredLabel.alpha = 1
					})
				})
			})
			.subscribe(onNext: { [weak self] _ in
				self?.toAuthSubject?.onNext(())
			}).disposed(by: disposeBag)

		// MARK: - Check keyboard showing
		keyboardHeight()
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [unowned self] keyboardHeight in
				if keyboardHeight > 0 {
					self.turnWarnings()
					// push up enter button
					self.pushupButtonUp(with: keyboardHeight)
					// push up logo
					self.view.logoImageView.snp.updateConstraints {
						$0.top.equalToSuperview().offset(self.logoTopOffset)
					}
					// push up login textField
					self.view.loginTextField.snp.updateConstraints {
						$0.top.equalTo(self.view.logoSubtitleLabel.snp.bottom).offset(self.logoSubtitleOffset)
					}
					// push up logo title
					self.view.logoTitleLabel.snp.updateConstraints {
						$0.top.equalTo(self.view.logoImageView.snp.bottom).offset(self.logoTitleOffset)
					}
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.view.layoutIfNeeded()
					})
				} else {
					self.currentKeyboardHeight = 0
					// push up enter button
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
						// check that keyboard not showing again
						guard self.currentKeyboardHeight == 0 else { return }
						
						self.view.enterButton.snp.updateConstraints {
							$0.bottom.equalToSuperview().offset(-71)
						}
						// push up logo
						self.view.logoImageView.snp.updateConstraints {
							$0.top.equalToSuperview()
						}
						// push up login textField
						self.view.loginTextField.snp.updateConstraints {
							$0.top.equalTo(self.view.logoSubtitleLabel.snp.bottom).offset(45)
						}
						// push up logo title
						self.view.logoTitleLabel.snp.updateConstraints {
							$0.top.equalTo(self.view.logoImageView.snp.bottom).offset(8)
						}
						UIView.animate(withDuration: self.animationDuration, animations: {
							self.view.view.layoutIfNeeded()
						})
					}
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

	// MARK: - Move enter button up
	private func pushupButtonUp(with keyboardHeight: CGFloat) {
		if currentKeyboardHeight == keyboardHeight {
			return
		}
		currentKeyboardHeight = keyboardHeight
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
			self.view.enterButton.snp.updateConstraints {
				$0.bottom.equalToSuperview().offset(-(self.currentKeyboardHeight + 10))
			}
			
			UIView.animate(withDuration: self.animationDuration, animations: {
				self.view.view.layoutIfNeeded()
			})
		}
	}

	// MARK: - Login flow
	private func registerUser() {
		let credentials = Observable.combineLatest(
			view.loginTextField.rx.text,
			view.passwordTextField.rx.text,
			view.confirmationPasswordTextField.rx.text,
			view.cityTextField.rx.text
		).filter { (login, password, confirmedPassword, city) -> Bool in
			return true
		}
		.map {(
			$0?.withoutExtraSpaces ?? "",
			$1?.withoutExtraSpaces ?? "",
			$2?.withoutExtraSpaces ?? "",
			$3?.withoutExtraSpaces ?? ""
			)}
		
		registrationSubject = PublishSubject<Any>()

		registrationSubject?
			.asObservable()
			.withLatestFrom(credentials)
			.filter { [unowned self] credentials in

				if !credentials.0.isValidEmail {
					self.turnWarnings(with: "auth.alert.uncorrect_email.title".localized)
				}

				switch credentials.1 {
				case let s where s.count < 8:
					self.turnWarnings(with: "registration.alert.password_too_short.title".localized)
					self.view.loadingView.stop()
					return false
				default: break
				}

				switch credentials.2 {
				case let s where s != credentials.1:
					self.turnWarnings(with: "registration.alert.passwords_different.title".localized)
				default: break
				}

				if self.view.alertLabel.text?.isEmpty ?? true {
					return true
				} else {
					self.view.loadingView.stop()
					return false
				}
			}
			.flatMap { [unowned self] credentials in
				self.di.registrationService.signUp(email: credentials.0,
												   password: credentials.1,
												   city: credentials.3,
												   userRole: self.userRole)
			}
			.filter { result in
				switch result {
				case .success:
					return true
				case .failure:
					self.view.loadingView.stop()
					return false
				}
			}
			.map { _ in }
			.flatMap {
				self.di.authService.signIn(email: self.di.keyChainService.getValue(for: Constants.KeyChainKeys.email) ?? "",
										   password: self.di.keyChainService.getValue(for: Constants.KeyChainKeys.password) ?? "")
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				self?.view.loadingView.stop()

				let id = "\(self?.di.localStorageService.getCurrenClientProfile()?.id ?? 0)"
				MRMyTracker.trackRegistrationEvent(id)

				switch result {
				case .success:
					self?.toSelectIssueSubject?.onNext(())
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

	private func checkAreTextFieldsEmpty() {
		
		guard
			let loginText = view.loginTextField.text,
			let passwordText = view.passwordTextField.text,
			let repeatedPasswordText = view.confirmationPasswordTextField.text,
			let cityText = view.cityTextField.text else { return }
		
		if !loginText.isEmpty,
			!passwordText.isEmpty,
			!repeatedPasswordText.isEmpty,
			!cityText.isEmpty {
			
			view.enterButton.isEnabled = true
			view.enterButton.backgroundColor = Colors.mainColor
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
			view.confirmationPasswordTextField.textColor = Colors.mainTextColor
			view.cityTextField.textColor = Colors.mainTextColor
		} else {
			view.view.endEditing(true)
			view.alertLabel.text = text
			
			view.loginTextField.textColor = Colors.warningColor
			view.passwordTextField.textColor = Colors.warningColor
			view.confirmationPasswordTextField.textColor = Colors.warningColor
			view.cityTextField.textColor = Colors.warningColor
		}
	}

	func removeBindings() {}
}
