//
//  AuthViewController.swift
//  Wheels
//
//  Created by Alexandr Bukharin on 23.06.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

protocol AuthViewControllerProtocol: class, ViewControllerProtocol {

	var logoImageView: UIImageView { get }
	var logoTitleLabel: UILabel { get }
	var logoSubtitleLabel: UILabel { get }

    var loginTextField: TextField { get }
    var passwordTextField: TextField { get }
    var enterButton: ConfirmButton { get }
	var loadingView: UIActivityIndicatorView { get }
	var faceIDButton: UIImageView { get }
	var registrationLabel: UILabel { get }
	var forgetPasswordLabel: UILabel { get }
}
/// Controller for auth screen
final class AuthViewController<modelType: ViewModel>: UIViewController,
AuthViewControllerProtocol where modelType.ViewType == AuthViewControllerProtocol {

	var logoImageView = UIImageView(image: #imageLiteral(resourceName: "logo_middle_icn"))
	var logoTitleLabel = UILabel()
	var logoSubtitleLabel = UILabel()
	
	var loginTextField = TextField()
	var passwordTextField = TextField()
	var enterButton = ConfirmButton(title: "auth.enter.title".localized)
	var loadingView = UIActivityIndicatorView(style: .medium)
	var faceIDButton = UIImageView(image: #imageLiteral(resourceName: "icn_face_id").withRenderingMode(.alwaysTemplate))
	var registrationLabel = UILabel()
	var forgetPasswordLabel = UILabel()
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
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.isNavigationBarHidden = true
		self.navigationItem.setHidesBackButton(true, animated:false)
	}

	
	private func addViews() {
		// logo imageView
		view.addSubview(logoImageView)
		logoImageView.snp.makeConstraints {
			$0.width.height.equalTo(84)
			$0.top.equalToSuperview().offset(81)
			$0.centerX.equalToSuperview()
		}
		// logo title
		view.addSubview(logoTitleLabel)
		logoTitleLabel.snp.makeConstraints {
			$0.height.equalTo(47)
			$0.top.equalTo(logoImageView.snp.bottom).offset(8)
			$0.centerX.equalToSuperview()
		}
		//logo subtitle
		view.addSubview(logoSubtitleLabel)
		logoSubtitleLabel.snp.makeConstraints {
			$0.top.equalTo(logoTitleLabel.snp.bottom).offset(-4)
			$0.height.equalTo(17)
			$0.centerX.equalToSuperview()
		}
		// login
		view.addSubview(loginTextField)
		loginTextField.snp.makeConstraints {
			$0.height.equalTo(48)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
			$0.centerX.equalToSuperview()
			$0.top.equalTo(logoSubtitleLabel.snp.bottom).offset(33)
		}
		// password
		view.addSubview(passwordTextField)
		passwordTextField.snp.makeConstraints() {
			$0.height.equalTo(48)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
			$0.centerX.equalToSuperview()
			$0.top.equalTo(loginTextField.snp.bottom)
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
	}
}
