//
//  AppealFromListViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 24.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit

protocol AppealFromListViewControllerProtocol: ViewControllerProtocol {
	var backButtonView: BackButtonView { get }
	var titleView: UIView { get }
	var titleTextField: TextField { get }
	var issueTypeLabel: UILabel { get }
	var descriptionTextView: UITextView { get }
	var chatButton: ConfirmButton { get }
	var profileView: UIView { get }
	var profileImageView: UIImageView { get }
	var profileNameLabel: UILabel { get }
	var loadingView: UIActivityIndicatorView { get }
}

final class AppealFromListViewController<modelType: AppealFromListViewModel>:
	UIViewController,
	UITableViewDelegate,
	UITextViewDelegate,
	AppealFromListViewControllerProtocol {

	var viewModel: modelType
	var backButtonView = BackButtonView()
	var titleView = UIView()
	var titleTextField = TextField()
	var issueTypeLabel = UILabel()

	var profileView = UIView()
	var profileImageView = UIImageView()
	var profileNameLabel = UILabel()

	var descriptionTextView = UITextView()
	var chatButton = ConfirmButton(title: "appeal.chatButton.titile".localized.uppercased(),
								   backgroundColor: Colors.greenColor)
	var navController: UINavigationController? {
		self.navigationController
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
		self.navigationItem.setHidesBackButton(true, animated:false)
	}

	func setNavigationBar() {
		let leftBarButtonItem = UIBarButtonItem(customView: backButtonView)
		self.navigationItem.leftBarButtonItem = leftBarButtonItem
		self.navigationItem.titleView = titleView
	}

	private func addViews() {
		// title
		titleView.addSubview(titleTextField)
		titleTextField.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.centerY.equalToSuperview().offset(2)
			$0.width.lessThanOrEqualTo(250)
		}
		titleView.snp.makeConstraints {
			$0.width.equalTo(titleTextField.snp.width).offset(46)
			$0.height.equalTo(40)
		}
		// issue type
		view.addSubview(issueTypeLabel)
		issueTypeLabel.snp.makeConstraints {
			$0.height.equalTo(24)
			$0.top.equalToSuperview().offset(90)
			$0.centerX.equalToSuperview()
			$0.width.lessThanOrEqualTo(300).priority(1000)
			$0.width.equalTo(issueTypeLabel.intrinsicContentSize.width + 20).priority(900)
		}

		// profile view
		view.addSubview(profileView)
		profileView.snp.makeConstraints {
			$0.top.equalTo(issueTypeLabel.snp.bottom).offset(15)
			$0.height.equalTo(36)
			$0.width.lessThanOrEqualTo(UIScreen.main.bounds.width - 40)
			$0.centerX.equalToSuperview()
		}
		profileView.addSubview(profileImageView)
		profileImageView.snp.makeConstraints {
			$0.width.height.equalTo(23)
			$0.leading.equalToSuperview().offset(9)
			$0.centerY.equalToSuperview()
		}
		profileView.addSubview(profileNameLabel)
		profileNameLabel.snp.makeConstraints {
			$0.height.equalTo(18)
			$0.leading.equalTo(profileImageView.snp.trailing).offset(9)
			$0.trailing.equalToSuperview().offset(-12)
			$0.centerY.equalToSuperview()
		}

		// description text view
		view.addSubview(descriptionTextView)
		descriptionTextView.snp.makeConstraints {
			$0.leading.equalToSuperview().offset(36)
			$0.trailing.equalToSuperview().offset(-36)
			$0.top.equalTo(profileView.snp.bottom).offset(23)
			$0.bottom.equalToSuperview().offset(-160)
		}
		view.addSubview(chatButton)
		chatButton.setImage(#imageLiteral(resourceName: "tab_chat_icn").withRenderingMode(.alwaysTemplate),
									  for: .normal)
		chatButton.imageView?.tintColor = Colors.whiteColor
		chatButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 0)
		chatButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
		chatButton.isHidden = true
		chatButton.snp.makeConstraints {
			$0.height.equalTo(49)
			$0.width.equalTo(142)
			$0.centerX.equalToSuperview()
			$0.bottom.equalToSuperview().offset(-100)
		}
		// loading view
		view.addSubview(loadingView)
		loadingView.hidesWhenStopped = true
		loadingView.snp.makeConstraints {
			$0.center.equalTo(view.snp.center)
		}
	}
}

