//
//  AuthViewController.swift
//  Wheels
//
//  Created by Alexandr Bukharin on 23.06.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

final class AuthViewController: UIViewController {
	
	var toMain: (() -> (Void))?
	private var loginTextField = TextField()
	private var passwordTextField = TextField()
	private var enterButton = ConfirmButton(title: "auth.enter.title".localized)

    override func viewDidLoad() {
        super.viewDidLoad()

		navigationController?.isNavigationBarHidden = true
		view.backgroundColor = Colors.authBackground
		addViews()
    }
	
	private func addViews() {
		// login
		loginTextField.keyboardType = .emailAddress
		loginTextField.attributedPlaceholder = NSAttributedString(string: "auth.login.placeholder".localized,
																  attributes: [NSAttributedString.Key.foregroundColor: Colors.placeholderColor])
		view.addSubview(loginTextField)
		loginTextField.snp.makeConstraints() {
			$0.height.equalTo(50)
			$0.centerX.equalToSuperview()
			$0.centerY.equalToSuperview().offset(-200)
			$0.leading.equalToSuperview().offset(30)
			$0.trailing.equalToSuperview().offset(-30)
		}
		
		// password
		passwordTextField.attributedPlaceholder = NSAttributedString(string: "auth.password.placeholder".localized,
																	 attributes: [NSAttributedString.Key.foregroundColor: Colors.placeholderColor])
		view.addSubview(passwordTextField)
		passwordTextField.snp.makeConstraints() {
			$0.height.equalTo(50)
			$0.centerX.equalToSuperview()
			$0.top.equalTo(loginTextField.snp.bottom).offset(30)
			$0.leading.equalToSuperview().offset(30)
			$0.trailing.equalToSuperview().offset(-30)
		}
		
		// enter button
		enterButton.addTarget(self,
							  action: #selector(didEnterTap),
							  for: .touchUpInside)
		view.addSubview(enterButton)
		enterButton.snp.makeConstraints() {
			$0.height.equalTo(50)
			$0.centerX.equalToSuperview()
			$0.top.equalTo(passwordTextField.snp.bottom).offset(30)
			$0.leading.equalToSuperview().offset(30)
			$0.trailing.equalToSuperview().offset(-30)
		}
	}
	
	@objc func didEnterTap() {
		view.endEditing(true)
		enterButton.isEnabled = false
		enterButton.animateBackground()
		
		guard
			loginTextField.text == "admin",
			passwordTextField.text == "12345"
			else { return }
		
		toMain?()
	}
}
