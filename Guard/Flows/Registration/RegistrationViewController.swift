//
//  RegistrationViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 11.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

protocol RegistratioViewControllerProtocol: class, ViewControllerProtocol {
	/// Pass to select issue screen
	var toSelectIssue: (() -> (Void))? { get }
	/// Pass to Auth
	var toAuth: (() -> (Void))? { get }
	var scrollView: UIScrollView { get }
	var logoTitleLabel: UILabel { get }
	var logoSubtitleLabel: UILabel { get }
	var loginTextField: TextField { get }
    var passwordTextField: TextField { get }
	var confirmationPasswordTextField: TextField { get }
	var cityTextField: TextField { get }
	var enterButton: ConfirmButton { get }
	var backButtonView: BackButtonView { get }
	var loadingView: UIActivityIndicatorView { get }
}

import UIKit
/// Controller for registration screen
final class RegistrationViewController<modelType: ViewModel>: UIViewController,
RegistratioViewControllerProtocol where modelType.ViewType == RegistratioViewControllerProtocol {

	var toSelectIssue: (() -> (Void))?
	var toAuth: (() -> (Void))?
	var viewModel: modelType
	
	var navController: UINavigationController? {
		return self.navigationController
	}
	
	var scrollView = UIScrollView()
	private var logoImageView = UIImageView(image: #imageLiteral(resourceName: "logo_middle_icn"))
	var logoTitleLabel = UILabel()
	var logoSubtitleLabel = UILabel()
	var loginTextField = TextField()
	var passwordTextField = TextField()
	var confirmationPasswordTextField = TextField()
	var cityTextField = TextField()
	var enterButton = ConfirmButton(title: "registration.sign_up.title".localized)
	var backButtonView = BackButtonView()
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
		self.navigationItem.setHidesBackButton(true, animated:false)
	}

	func setNavigationBar() {
		let leftBarButtonItem = UIBarButtonItem(customView: backButtonView)
		self.navigationItem.leftBarButtonItem = leftBarButtonItem
	}

	@objc func backToMain() {
		self.navigationController?.popViewController(animated: true)
	}

	private func addViews() {
		// scroll view
		view.addSubview(scrollView)
		scrollView.snp.makeConstraints() {
			$0.edges.equalToSuperview()
		}
		// logo imageView
		scrollView.addSubview(logoImageView)
		logoImageView.snp.makeConstraints() {
			$0.width.height.equalTo(84)
			$0.top.equalToSuperview()
			$0.centerX.equalToSuperview()
		}
		// logo title
		scrollView.addSubview(logoTitleLabel)
		logoTitleLabel.snp.makeConstraints() {
			$0.height.equalTo(47)
			$0.top.equalTo(logoImageView.snp.bottom).offset(8)
			$0.centerX.equalToSuperview()
		}
		//logo subtitle
		scrollView.addSubview(logoSubtitleLabel)
		logoSubtitleLabel.snp.makeConstraints() {
			$0.top.equalTo(logoTitleLabel.snp.bottom).offset(-4)
			$0.height.equalTo(17)
			$0.centerX.equalToSuperview()
		}
		// login
		scrollView.addSubview(loginTextField)
		loginTextField.snp.makeConstraints() {
			$0.height.equalTo(48)
			$0.width.equalTo(130)
			$0.centerX.equalToSuperview()
			$0.top.equalTo(logoSubtitleLabel.snp.bottom).offset(45)
		}
		// password
		scrollView.addSubview(passwordTextField)
		passwordTextField.snp.makeConstraints() {
			$0.height.equalTo(48)
			$0.width.equalTo(130)
			$0.centerX.equalToSuperview()
			$0.top.equalTo(loginTextField.snp.bottom)
		}
		// confirmation password
		scrollView.addSubview(confirmationPasswordTextField)
		confirmationPasswordTextField.snp.makeConstraints() {
			$0.height.equalTo(48)
			$0.width.equalTo(130)
			$0.centerX.equalToSuperview()
			$0.top.equalTo(passwordTextField.snp.bottom)
		}
		// city
		scrollView.addSubview(cityTextField)
		cityTextField.snp.makeConstraints() {
			$0.height.equalTo(48)
			$0.width.equalTo(130)
			$0.centerX.equalToSuperview()
			$0.top.equalTo(confirmationPasswordTextField.snp.bottom)
		}
		// enter button
		scrollView.addSubview(enterButton)
		enterButton.snp.makeConstraints() {
			$0.height.equalTo(50)
			$0.width.equalTo(116)
			$0.centerX.equalToSuperview()
			$0.top.equalTo(cityTextField.snp.bottom).offset(70)
			$0.bottom.equalToSuperview().offset(-100)
		}
		// loading view
		scrollView.addSubview(loadingView)
		loadingView.hidesWhenStopped = true
        loadingView.snp.makeConstraints {
            $0.center.equalTo(scrollView.snp.center)
        }
	}
}
