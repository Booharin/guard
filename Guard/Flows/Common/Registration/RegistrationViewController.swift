//
//  RegistrationViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 11.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

protocol RegistratioViewControllerProtocol: AnyObject, ViewControllerProtocol {
	var scrollView: UIScrollView { get }
	
	var logoImageView: UIImageView { get }
	var logoTitleLabel: UILabel { get }
	var logoSubtitleLabel: UILabel { get }
	
	var loginTextField: TextField { get }
	var passwordTextField: TextField { get }
	var confirmationPasswordTextField: TextField { get }
	var citySelectView: SelectButtonView { get }
	var alertLabel: UILabel { get }
	
	var enterButton: ConfirmButton { get }
	var backButtonView: BackButtonView { get }
	var skipButton: SkipButton { get }
	var alreadyRegisteredLabel: UILabel { get }

	var loadingView: LottieAnimationView { get }
	func showActionSheet(with titles: [String], completion: @escaping (String) -> Void)
}

import UIKit
/// Controller for registration screen
final class RegistrationViewController<modelType: ViewModel>: UIViewController,
RegistratioViewControllerProtocol where modelType.ViewType == RegistratioViewControllerProtocol {
	var viewModel: modelType
	
	var navController: UINavigationController? {
		return self.navigationController
	}
	
	var scrollView = UIScrollView()
	
	var logoImageView = UIImageView(image: #imageLiteral(resourceName: "logo_middle_icn"))
	var logoTitleLabel = UILabel()
	var logoSubtitleLabel = UILabel()
	
	var loginTextField = TextField()
	var passwordTextField = TextField()
	var confirmationPasswordTextField = TextField()
	var citySelectView = SelectButtonView()
	var alertLabel = UILabel()

	var enterButton = ConfirmButton(title: "registration.sign_up.title".localized.uppercased())
	var backButtonView = BackButtonView()
	var skipButton = SkipButton(title: "registration.skip.title".localized,
								font: Saira.light.of(size: 15))
	var alreadyRegisteredLabel = UILabel()

	var loadingView = LottieAnimationView()
	
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
		//let rightBarButtonItem = UIBarButtonItem(customView: skipButton)
		self.navigationItem.leftBarButtonItem = leftBarButtonItem
		//self.navigationItem.rightBarButtonItem = rightBarButtonItem
	}
	
	private func addViews() {
		// scroll view
		view.addSubview(scrollView)
		scrollView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
		// logo imageView
		scrollView.addSubview(logoImageView)
		logoImageView.snp.makeConstraints {
			$0.width.height.equalTo(84)
			$0.top.equalToSuperview()
			$0.centerX.equalToSuperview()
		}
		// logo title
		scrollView.addSubview(logoTitleLabel)
		logoTitleLabel.snp.makeConstraints {
			$0.height.equalTo(47)
			$0.top.equalTo(logoImageView.snp.bottom).offset(8)
			$0.centerX.equalToSuperview()
		}
		//logo subtitle
		scrollView.addSubview(logoSubtitleLabel)
		logoSubtitleLabel.snp.makeConstraints {
			$0.top.equalTo(logoTitleLabel.snp.bottom).offset(-4)
			$0.height.equalTo(17)
			$0.centerX.equalToSuperview()
		}
		// login
		scrollView.addSubview(loginTextField)
		loginTextField.snp.makeConstraints {
			$0.height.equalTo(48)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
			$0.centerX.equalToSuperview()
			$0.top.equalTo(logoSubtitleLabel.snp.bottom).offset(45)
		}
		// password
		scrollView.addSubview(passwordTextField)
		passwordTextField.snp.makeConstraints {
			$0.height.equalTo(48)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
			$0.centerX.equalToSuperview()
			$0.top.equalTo(loginTextField.snp.bottom)
		}
		// confirmation password
		scrollView.addSubview(confirmationPasswordTextField)
		confirmationPasswordTextField.snp.makeConstraints {
			$0.height.equalTo(48)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
			$0.centerX.equalToSuperview()
			$0.top.equalTo(passwordTextField.snp.bottom)
		}
		// city
		scrollView.addSubview(citySelectView)
		citySelectView.snp.makeConstraints {
			$0.top.equalTo(confirmationPasswordTextField.snp.bottom)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
			$0.height.equalTo(48)
			$0.centerX.equalToSuperview()
		}
		// alert label
		scrollView.addSubview(alertLabel)
		alertLabel.snp.makeConstraints {
			$0.top.equalTo(citySelectView.snp.bottom).offset(20)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
			$0.bottom.equalToSuperview()
		}
		// enter button
		view.addSubview(enterButton)
		enterButton.snp.makeConstraints() {
			$0.height.equalTo(50)
			$0.width.greaterThanOrEqualTo(116)
			$0.centerX.equalToSuperview()
			$0.bottom.equalToSuperview().offset(-71)
		}
		// already registered button
		view.addSubview(alreadyRegisteredLabel)
		alreadyRegisteredLabel.snp.makeConstraints() {
			$0.height.equalTo(30)
			$0.centerX.equalToSuperview()
			$0.bottom.equalToSuperview().offset(-25)
		}
		// loading view
		scrollView.addSubview(loadingView)
		loadingView.snp.makeConstraints {
			$0.center.equalToSuperview()
			$0.width.height.equalTo(300)
		}
	}

	// MARK: - Show action sheet
	func showActionSheet(with titles: [String], completion: @escaping (String) -> Void) {
		let alertController = UIAlertController(title: nil,
												message: nil,
												preferredStyle: .actionSheet)
		alertController.view.tintColor = Colors.mainTextColor
		titles.forEach { title in
			let cityAction = UIAlertAction(title: title, style: .default, handler: { _ in
				completion(title)
				alertController.dismiss(animated: true)
			})
			alertController.addAction(cityAction)
		}
		let cancelAction = UIAlertAction(title: "alert.cancel".localized, style: .cancel, handler: { _ in
			alertController.dismiss(animated: true)
		})
		alertController.addAction(cancelAction)
		self.present(alertController, animated: true)
	}
}
