//
//  AuthViewController.swift
//  Wheels
//
//  Created by Alexandr Bukharin on 23.06.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

protocol AuthViewControllerProtocol: class, ViewControllerProtocol {
    var loginTextField: TextField { get }
    var passwordTextField: TextField { get }
    var enterButton: ConfirmButton { get }
	var toMain: (() -> (Void))? { get }
	var loadingView: UIActivityIndicatorView { get }
	var faceIDButton: UIImageView { get }
	var registrationLabel: UILabel { get }
	var forgetPasswordLabel: UILabel { get }
	var backButtonView: BackButtonView { get }
}
/// Controller for auth screen
final class AuthViewController<modelType: ViewModel>: UIViewController,
AuthViewControllerProtocol where modelType.ViewType == AuthViewControllerProtocol {
	// Pass to main
	var toMain: (() -> (Void))?
	var loginTextField = TextField()
	var passwordTextField = TextField()
	var enterButton = ConfirmButton(title: "auth.enter.title".localized)
	var loadingView = UIActivityIndicatorView(style: .medium)
	var faceIDButton = UIImageView(image: #imageLiteral(resourceName: "icn_face_id").withRenderingMode(.alwaysTemplate))
	var registrationLabel = UILabel()
	var forgetPasswordLabel = UILabel()
	var backButtonView = BackButtonView()
	var viewModel: modelType
	var navController: UINavigationController? {
		return self.navigationController
	}
	private var isFromRegistration: Bool
	
	init(viewModel: modelType,
		 isFromRegistration: Bool = false) {
        self.viewModel = viewModel
		self.isFromRegistration = isFromRegistration
        super.init(nibName: nil, bundle: nil)
    }
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.viewModel.assosiateView(self)
		view.backgroundColor = Colors.whiteColor
		addViews()
    }
	
	private func addViews() {
		// login
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
		view.addSubview(enterButton)
		enterButton.snp.makeConstraints() {
			$0.height.equalTo(50)
			$0.centerX.equalToSuperview()
			$0.bottom.equalToSuperview().offset(-30)
			$0.leading.equalToSuperview().offset(30)
			$0.trailing.equalToSuperview().offset(-30)
		}
		// loading view
		view.addSubview(loadingView)
		loadingView.hidesWhenStopped = true
        loadingView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
		// registration label
		view.addSubview(registrationLabel)
		registrationLabel.snp.makeConstraints() {
			$0.leading.equalTo(passwordTextField.snp.leading).offset(5)
			$0.top.equalTo(passwordTextField.snp.bottom).offset(10)
			$0.height.equalTo(50)
		}
		// forget Password Label
		view.addSubview(forgetPasswordLabel)
		forgetPasswordLabel.snp.makeConstraints() {
			$0.trailing.equalTo(passwordTextField.snp.trailing).offset(-5)
			$0.top.equalTo(passwordTextField.snp.bottom).offset(10)
			$0.height.equalTo(50)
		}
		// face id button
		view.addSubview(faceIDButton)
		faceIDButton.snp.makeConstraints() {
			$0.trailing.equalTo(forgetPasswordLabel.snp.trailing)
			$0.top.equalTo(passwordTextField.snp.bottom).offset(60)
			$0.width.height.equalTo(50)
		}
		// back button
		guard isFromRegistration == true else { return }
		view.addSubview(backButtonView)
		backButtonView.snp.makeConstraints() {
			$0.width.height.equalTo(50)
			$0.top.equalToSuperview().offset(50)
			$0.leading.equalToSuperview().offset(10)
		}
	}
}
