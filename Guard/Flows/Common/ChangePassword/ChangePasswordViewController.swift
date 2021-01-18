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
	var loadingView: UIActivityIndicatorView { get }
}

final class ChangePasswordViewController<modelType: ChangePasswordViewModel>:
	UIViewController,
	ChangePasswordViewControllerProtocol {

	var backButtonView = BackButtonView()
	var titleView = UIView()
	var titleLabel = UILabel()
	private var gradientView: UIView?
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

	}
}
