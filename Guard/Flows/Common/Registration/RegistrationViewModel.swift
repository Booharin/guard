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

final class RegistrationViewModel: ViewModel, HasDependencies {
	var view: RegistratioViewControllerProtocol!
	private let animationDuration = 0.15
	var registrationSubject: PublishSubject<Any>?
	private var disposeBag = DisposeBag()
	private let userType: UserType

	typealias Dependencies =
	HasLocationService &
	HasLocalStorageService
	lazy var di: Dependencies = DI.dependencies

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
		 userType: UserType) {
		self.toSelectIssueSubject = toSelectIssueSubject
		self.toAuthSubject = toAuthSubject
		self.userType = userType
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
		view.passwordTextField.isSecureTextEntry = true
		view.passwordTextField.configure(placeholderText: "registration.password.placeholder".localized)
		view.passwordTextField
			.rx
			.text
			.subscribe(onNext: { [unowned self] _ in
				self.checkAreTextFieldsEmpty()
			}).disposed(by: disposeBag)

		// confirmation password
		view.confirmationPasswordTextField.configure(placeholderText: "registration.confirm_password.placeholder".localized)
		view.confirmationPasswordTextField.isSecureTextEntry = true
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
				self.registerUser()
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
		view.skipButtonView
			.rx
			.tapGesture()
			.when(.recognized)
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.skipButtonView.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.skipButtonView.alpha = 1
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
		
		defineCity()
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
					return false
				}
		}
		.observeOn(MainScheduler.instance)
		.subscribe(onNext: { [weak self] _ in
			self?.view.loadingView.stopAnimating()

			self?.saveProfileToStorage()

			self?.toSelectIssueSubject?.onNext(())
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

	//MARK: - Define city
	private func defineCity() {
		di.locationService.geocode { [weak self] city in
			guard let city = city else { return }
			self?.view.cityTextField.text = city
		}
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
	
	private func saveProfileToStorage() {
		// mock getting profile from server
		var userProfileDict: [String : Any] = [
			"email": view.loginTextField.text ?? "",
			"firstName": "",
			"lastName": "",
			"country": "Russia",
			"photo": "www.apple.com",
			"id": 0,
			"dateCreated": Int(Date().timeIntervalSince1970),
			"city": view.cityTextField.text ?? "",
			"phone": "03",
			"rate": 5.5
		]

		do {
			switch userType {
			case .client:
				let jsonData = try JSONSerialization.data(withJSONObject: userProfileDict,
														  options: .prettyPrinted)
				let profileResponse = try JSONDecoder().decode(ClientProfile.self, from: jsonData)
				di.localStorageService.saveProfile(profileResponse)
			case .lawyer:
				userProfileDict["issueTypes"] = []
				let jsonData = try JSONSerialization.data(withJSONObject: userProfileDict,
														  options: .prettyPrinted)
				let profileResponse = try JSONDecoder().decode(LawyerProfile.self, from: jsonData)
				di.localStorageService.saveProfile(profileResponse)
			}

			UserDefaults.standard.set(true,
									  forKey: Constants.UserDefaultsKeys.isLogin)
		} catch {
			#if DEBUG
			print(error)
			#endif
		}
	}

	func removeBindings() {}
}
