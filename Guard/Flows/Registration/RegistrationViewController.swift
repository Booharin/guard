//
//  RegistrationViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 11.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

protocol RegistratioViewControllerProtocol: class, ViewControllerProtocol {
	var toMain: (() -> (Void))? { get }
	var toAuth: (() -> (Void))? { get }
	var scrollView: UIScrollView { get }
	var loginTextField: TextField { get }
    var passwordTextField: TextField { get }
	var confirmationPasswordTextField: TextField { get }
	var enterButton: ConfirmButton { get }
	var backButtonView: BackButtonView { get }
}

import UIKit
/// Controller for registration screen
final class RegistrationViewController<modelType: ViewModel>: UIViewController,
RegistratioViewControllerProtocol where modelType.ViewType == RegistratioViewControllerProtocol {
	
	/// Pass to main screen
	var toMain: (() -> (Void))?
	/// Pass to Auth
	var toAuth: (() -> (Void))?
	/// View model
	var viewModel: modelType
	
	var navController: UINavigationController? {
		return self.navigationController
	}
	
	var scrollView = UIScrollView()
	var loginTextField = TextField()
	var passwordTextField = TextField()
	var confirmationPasswordTextField = TextField()
	var enterButton = ConfirmButton()
	var backButtonView = BackButtonView()
	
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
		view.backgroundColor = Colors.authBackground
		addViews()
    }
	
//	override func viewWillAppear(_ animated: Bool) {
//		super.viewWillAppear(animated)
//		
//		//setNavigationBar()
//	}
//	
//	private func setNavigationBar() {
//		navigationController?.isNavigationBarHidden = false
//        self.navigationItem.setHidesBackButton(true, animated:false)
//		
//		let backButtonView = BackButtonView()
//        
//        let backTap = UITapGestureRecognizer(target: self, action: #selector(back))
//        view.addGestureRecognizer(backTap)
//        let leftBarButtonItem = UIBarButtonItem(customView: backButtonView)
//        self.navigationItem.leftBarButtonItem = leftBarButtonItem
//    }
//    
//    @objc private func back() {
//		self.navigationController?.popViewController(animated: true)
//    }

	private func addViews() {
		/// scroll view
		view.addSubview(scrollView)
		scrollView.snp.makeConstraints() {
			$0.edges.equalToSuperview()
		}
		/// login
		scrollView.addSubview(loginTextField)
		loginTextField.snp.makeConstraints() {
			$0.height.equalTo(50)
			$0.centerX.equalToSuperview()
			$0.top.equalToSuperview().offset(100)
			$0.leading.equalToSuperview().offset(30)
			$0.trailing.equalToSuperview().offset(-30)
		}
		/// password
		scrollView.addSubview(passwordTextField)
		passwordTextField.snp.makeConstraints() {
			$0.height.equalTo(50)
			$0.centerX.equalToSuperview()
			$0.top.equalTo(loginTextField.snp.bottom).offset(30)
			$0.leading.equalToSuperview().offset(30)
			$0.trailing.equalToSuperview().offset(-30)
		}
		/// confirmation password
		scrollView.addSubview(confirmationPasswordTextField)
		confirmationPasswordTextField.snp.makeConstraints() {
			$0.height.equalTo(50)
			$0.centerX.equalToSuperview()
			$0.top.equalTo(passwordTextField.snp.bottom).offset(30)
			$0.bottom.equalToSuperview().offset(-100)
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
		// back button
		view.addSubview(backButtonView)
		backButtonView.snp.makeConstraints() {
			$0.width.height.equalTo(50)
			$0.top.equalToSuperview().offset(50)
			$0.leading.equalToSuperview().offset(10)
		}
	}
}
