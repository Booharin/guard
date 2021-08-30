//
//  AuthViewController.swift
//  Wheels
//
//  Created by Alexandr Bukharin on 23.06.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

protocol AuthViewControllerProtocol: AnyObject, ViewControllerProtocol {
	
	var logoImageView: UIImageView { get }
	var logoTitleLabel: UILabel { get }
	var logoSubtitleLabel: UILabel { get }
	
	var loginTextField: TextField { get }
	var passwordTextField: TextField { get }
	var enterButton: ConfirmButton { get }
	var registrationButton: ConfirmButton { get }
	var faceIDButton: ConfirmButton { get }
	var forgetPasswordLabel: UILabel { get }
	var alertLabel: UILabel { get }
	var loadingView: LottieAnimationView { get }
}
/// Controller for auth screen
final class AuthViewController<modelType: ViewModel>: UIViewController,
AuthViewControllerProtocol where modelType.ViewType == AuthViewControllerProtocol {
	
	var logoImageView = UIImageView(image: #imageLiteral(resourceName: "logo_middle_icn"))
	var logoTitleLabel = UILabel()
	var logoSubtitleLabel = UILabel()
	
	var loginTextField = TextField()
	var passwordTextField = TextField()
	var enterButton = ConfirmButton(title: "auth.enter.title".localized.uppercased(),
									backgroundColor: Colors.buttonDisabledColor)
	var registrationButton = ConfirmButton(title: "auth.registration.title".localized.uppercased(),
										   backgroundColor: Colors.mainColor,
										   cornerRadius: 20)
	var faceIDButton = ConfirmButton(backgroundColor: Colors.whiteColor,
									 cornerRadius: 20,
									 image: #imageLiteral(resourceName: "icn_face_id").withRenderingMode(.alwaysTemplate))
	var forgetPasswordLabel = UILabel()
	var loadingView = LottieAnimationView()
	var alertLabel = UILabel()
	
	var viewModel: modelType
	var navController: UINavigationController? {
		return self.navigationController
	}

	init(viewModel: modelType) {
		self.viewModel = viewModel
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

		navigationController?.setNavigationBarHidden(true, animated: true)
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
		passwordTextField.snp.makeConstraints {
			$0.height.equalTo(48)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
			$0.centerX.equalToSuperview()
			$0.top.equalTo(loginTextField.snp.bottom)
		}
		// enter button
		view.addSubview(enterButton)
		enterButton.snp.makeConstraints {
			$0.height.equalTo(50)
			$0.centerX.equalToSuperview()
			$0.top.equalTo(passwordTextField.snp.bottom).offset(15)
			$0.width.equalTo(210)
		}
		// loading view
		view.addSubview(loadingView)
		loadingView.snp.makeConstraints {
			$0.center.equalToSuperview()
			$0.width.height.equalTo(300)
		}
		// registration button
		view.addSubview(registrationButton)
		registrationButton.snp.makeConstraints {
			$0.leading.equalTo(enterButton.snp.leading)
			$0.top.equalTo(enterButton.snp.bottom).offset(14)
			$0.height.equalTo(40)
			$0.width.greaterThanOrEqualTo(100)
		}
		// face id button
		view.addSubview(faceIDButton)
		faceIDButton.snp.makeConstraints {
			$0.leading.equalTo(registrationButton.snp.trailing).offset(10)
			$0.trailing.equalTo(enterButton.snp.trailing)
			$0.top.equalTo(enterButton.snp.bottom).offset(14)
			$0.height.equalTo(40)
			$0.width.lessThanOrEqualTo(100)
			$0.width.greaterThanOrEqualTo(60)
		}
		// forget Password Label
		view.addSubview(forgetPasswordLabel)
		forgetPasswordLabel.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.top.equalTo(enterButton.snp.bottom).offset(70)
			$0.height.equalTo(30)
		}
		// alert label
		view.addSubview(alertLabel)
		alertLabel.snp.makeConstraints {
			$0.top.equalTo(forgetPasswordLabel.snp.bottom).offset(15)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
		}
	}
}
