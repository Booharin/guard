//
//  ForgotPasswordViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 02.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

protocol ForgotPasswordViewControllerProtocol: class, ViewControllerProtocol {
	var logoImageView: UIImageView { get }
	var logoTitleLabel: UILabel { get }
	var logoSubtitleLabel: UILabel { get }
	
	var hintLabel: UILabel { get }
	var loginTextField: TextField { get }
	var alertLabel: UILabel { get }
	var sendButton: ConfirmButton { get }
	var backButtonView: BackButtonView { get }
	var loadingView: UIActivityIndicatorView { get }
}

final class ForgotPasswordViewController<modelType: ViewModel>: UIViewController,
ForgotPasswordViewControllerProtocol where modelType.ViewType == ForgotPasswordViewControllerProtocol {
	
	var logoImageView = UIImageView(image: #imageLiteral(resourceName: "logo_middle_icn"))
	var logoTitleLabel = UILabel()
	var logoSubtitleLabel = UILabel()
	
	var hintLabel = UILabel()
	var loginTextField = TextField()
	var alertLabel = UILabel()
	var sendButton = ConfirmButton(title: "forgot.password.send.title".localized.uppercased())
	var backButtonView = BackButtonView()
	
	var viewModel: modelType
	
	var navController: UINavigationController? {
		return self.navigationController
	}
	
	var loadingView = UIActivityIndicatorView(style: .medium)
	
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
		setNavigationBar()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
		self.navigationItem.setHidesBackButton(true, animated:false)
	}
	
	func setNavigationBar() {
		let leftBarButtonItem = UIBarButtonItem(customView: backButtonView)
		self.navigationItem.leftBarButtonItem = leftBarButtonItem
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
		// hint label
		view.addSubview(hintLabel)
		hintLabel.snp.makeConstraints {
			$0.top.equalTo(logoSubtitleLabel.snp.bottom).offset(20)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
		}
		// login
		view.addSubview(loginTextField)
		loginTextField.snp.makeConstraints {
			$0.height.equalTo(48)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
			$0.centerX.equalToSuperview()
			$0.top.equalTo(hintLabel.snp.bottom).offset(30)
		}
		// alert label
		view.addSubview(alertLabel)
		alertLabel.snp.makeConstraints {
			$0.top.equalTo(loginTextField.snp.bottom).offset(20)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
		}
		// enter button
		view.addSubview(sendButton)
		sendButton.snp.makeConstraints {
			$0.height.equalTo(50)
			$0.width.greaterThanOrEqualTo(116)
			$0.centerX.equalToSuperview()
			$0.bottom.equalToSuperview().offset(-71)
		}
		// loading view
		view.addSubview(loadingView)
		loadingView.hidesWhenStopped = true
		loadingView.snp.makeConstraints {
			$0.center.equalTo(view.snp.center)
		}
	}
}
