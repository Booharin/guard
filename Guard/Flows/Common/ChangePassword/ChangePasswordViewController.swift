//
//  ChangePasswordViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 18.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit

protocol ChangePasswordViewControllerProtocol: ViewControllerProtocol {
	var backButtonView: BackButtonView { get }
	var titleView: UIView { get }
	var titleLabel: UILabel { get }
	var alertLabel: UILabel { get }
	var oldPasswordTextField: TextField { get }
	var newPasswordTextField: TextField { get }
	var saveButton: ConfirmButton { get }
	var loadingView: UIActivityIndicatorView { get }
}

final class ChangePasswordViewController<modelType: ChangePasswordViewModel>:
	UIViewController,
	ChangePasswordViewControllerProtocol {

	var backButtonView = BackButtonView()
	var titleView = UIView()
	var titleLabel = UILabel()
	var alertLabel = UILabel()
	var oldPasswordTextField = TextField()
	var newPasswordTextField = TextField()
	var saveButton = ConfirmButton(title: "change_password.save_password.title".localized.uppercased())
	var navController: UINavigationController? {
		self.navigationController
	}
	var loadingView = UIActivityIndicatorView(style: .medium)

	var viewModel: modelType

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

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
	}

	private func setNavigationBar() {
		let leftBarButtonItem = UIBarButtonItem(customView: backButtonView)
		self.navigationItem.leftBarButtonItem = leftBarButtonItem
		self.navigationItem.titleView = titleView
	}

	private func addViews() {
		// title view
		titleView.addSubview(titleLabel)
		titleLabel.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.centerY.equalToSuperview().offset(2)
			$0.width.lessThanOrEqualTo(250)
		}
		titleView.snp.makeConstraints {
			$0.width.equalTo(titleLabel.snp.width).offset(46)
			$0.height.equalTo(40)
		}
		// old password
		view.addSubview(oldPasswordTextField)
		oldPasswordTextField.snp.makeConstraints {
			$0.height.equalTo(48)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
			$0.centerX.equalToSuperview()
			$0.top.equalToSuperview().offset(200)
		}
		// new password
		view.addSubview(newPasswordTextField)
		newPasswordTextField.snp.makeConstraints {
			$0.height.equalTo(48)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
			$0.centerX.equalToSuperview()
			$0.top.equalTo(oldPasswordTextField.snp.bottom)
		}
		// alert label
		view.addSubview(alertLabel)
		alertLabel.snp.makeConstraints {
			$0.top.equalTo(newPasswordTextField.snp.bottom).offset(20)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
		}
		// save button
		view.addSubview(saveButton)
		saveButton.snp.makeConstraints {
			$0.height.equalTo(50)
			$0.width.greaterThanOrEqualTo(100)
			$0.centerX.equalToSuperview()
			$0.bottom.equalToSuperview().offset(-71)
		}
		// loading view
		view.addSubview(loadingView)
		loadingView.hidesWhenStopped = true
		loadingView.snp.makeConstraints {
			$0.center.equalToSuperview()
		}
	}
}
