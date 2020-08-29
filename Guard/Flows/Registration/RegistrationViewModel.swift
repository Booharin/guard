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
	private let textFieldAnimationDuration = 0.05
	var registrationSubject: PublishSubject<Any>?
	private var disposeBag = DisposeBag()
	
	typealias Dependencies =
        HasLocationService
    lazy var di: Dependencies = DI.dependencies
	
	func viewDidSet() {
		// logo
		view.logoTitleLabel.font = Saira.bold.of(size: 30)
		view.logoTitleLabel.textColor = Colors.maintextColor
		view.logoTitleLabel.text = "registration.logo.title".localized.uppercased()
		
		view.logoSubtitleLabel.font = SFUIDisplay.regular.of(size: 14)
		view.logoSubtitleLabel.textColor = Colors.maintextColor
		view.logoSubtitleLabel.text = "registration.logo.subtitle".localized
		// login
		view.loginTextField.keyboardType = .emailAddress
		view.loginTextField.configure(placeholderText: "registration.login.placeholder".localized)
		view.loginTextField
		.rx
		.text
		.subscribe(onNext: { [unowned self] in
			guard let text = $0 else { return }
		}).disposed(by: disposeBag)

		// password
		view.passwordTextField.isSecureTextEntry = true
		view.passwordTextField.configure(placeholderText: "registration.password.placeholder".localized)
		view.passwordTextField
				.rx
				.text
				.subscribe(onNext: { [unowned self] in
					guard let text = $0 else { return }
				}).disposed(by: disposeBag)
		
		// confirmation password
		view.confirmationPasswordTextField.configure(placeholderText: "registration.confirm_password.placeholder".localized)
		view.confirmationPasswordTextField.isSecureTextEntry = true
		view.confirmationPasswordTextField
				.rx
				.text
				.subscribe(onNext: { [unowned self] in
					guard let text = $0 else { return }
				}).disposed(by: disposeBag)
		
		//city
		view.cityTextField.configure(placeholderText: "registration.city.placeholder".localized)
		view.cityTextField
		.rx
		.text
		.subscribe(onNext: { [unowned self] in
			guard let text = $0 else { return }
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
					var contentInset:UIEdgeInsets = self.view.scrollView.contentInset
					contentInset.bottom = keyboardHeight + 100
					self.view.scrollView.contentInset = contentInset
				} else {
					let contentInset:UIEdgeInsets = UIEdgeInsets.zero
					self.view.scrollView.contentInset = contentInset
				}
            })
            .disposed(by: disposeBag)
		
		defineCity()
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
//        .filter { [unowned self] credentials in
//			switch credentials.0 {
//			case let s where s.count == 0:
//				self.view.loginTextField.alertLabel.text = "registration.alert.empty.title".localized
//			case let s where s.isValidEmail == false:
//				self.view.loginTextField.alertLabel.text = "registration.alert.uncorrect_email.title".localized
//			default: break
//			}
//			
//			switch credentials.1 {
//			case let s where s.count == 0:
//				self.view.passwordTextField.alertLabel.text = "registration.alert.empty.title".localized
//			case let s where s.count < 8:
//				self.view.passwordTextField.alertLabel.text = "registration.alert.password_too_short.title".localized
//			default: break
//			}
//			
//			switch credentials.2 {
//			case let s where s.count == 0:
//				self.view.confirmationPasswordTextField.alertLabel.text = "registration.alert.empty.title".localized
//			case let s where s != credentials.1:
//				self.view.confirmationPasswordTextField.alertLabel.text = "registration.alert.passwords_different.title".localized
//			default: break
//			}
//			
//			if self.view.loginTextField.alertLabel.text?.isEmpty ?? false &&
//				self.view.passwordTextField.alertLabel.text?.isEmpty ?? false &&
//				self.view.confirmationPasswordTextField.alertLabel.text?.isEmpty ?? false {
//				return true
//			} else {
//				return false
//			}
//        }
		.observeOn(MainScheduler.instance)
		.subscribe(onNext: { [weak self] _ in
			self?.view.loadingView.stopAnimating()
			self?.view.toSelectIssue?()
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
	
	func removeBindings() {}
}
