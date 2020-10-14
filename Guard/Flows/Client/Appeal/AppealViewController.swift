//
//  AppealViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 14.10.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

protocol AppealViewControllerProtocol: ViewControllerProtocol {
	var scrollView: UIScrollView { get }
	var backButtonView: BackButtonView { get }
	var threedotsButtonView: ThreeDotsButtonView { get }
	var titleView: UIView { get }
	var titleLabel: UILabel { get }
	var issueTypeLabel: UILabel { get }
	var issueDescriptionLabel: UILabel { get }
	var lawyerSelectedButton: UIButton { get }
}

final class AppealViewController<modelType: AppealViewModel>:
	UIViewController,
	UITableViewDelegate,
	AppealViewControllerProtocol {

	var viewModel: modelType
	var scrollView = UIScrollView()
	var backButtonView = BackButtonView()
	var threedotsButtonView = ThreeDotsButtonView()
	var titleView = UIView()
	var titleLabel = UILabel()
	var issueTypeLabel = UILabel()
	var issueDescriptionLabel = UILabel()
	var lawyerSelectedButton = UIButton()
    var navController: UINavigationController? {
        self.navigationController
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
		setNavigationBar()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.isNavigationBarHidden = false
		self.navigationItem.setHidesBackButton(true, animated:false)
	}

	func setNavigationBar() {
		let leftBarButtonItem = UIBarButtonItem(customView: backButtonView)
		let rightBarButtonItem = UIBarButtonItem(customView: threedotsButtonView)
		self.navigationItem.leftBarButtonItem = leftBarButtonItem
		self.navigationItem.rightBarButtonItem = rightBarButtonItem
		self.navigationItem.titleView = titleView
	}

	private func addViews() {
		// title
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
		// issue type
		view.addSubview(issueTypeLabel)
		issueTypeLabel.snp.makeConstraints {
			$0.height.equalTo(24)
			$0.top.equalToSuperview().offset(90)
            $0.centerX.equalToSuperview()
            $0.width.lessThanOrEqualTo(300).priority(1000)
            $0.width.equalTo(issueTypeLabel.intrinsicContentSize.width + 20).priority(900)
		}
		// scroll
		view.addSubview(scrollView)
		scrollView.snp.makeConstraints {
            $0.top.equalTo(issueTypeLabel.snp.bottom).offset(20)
            $0.leading.trailing.bottom.equalToSuperview()
		}
        // description
        scrollView.addSubview(issueDescriptionLabel)
        issueDescriptionLabel.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width - 72)
            $0.leading.equalToSuperview().offset(36)
            $0.trailing.equalToSuperview().offset(-36)
            $0.height.equalTo(20)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-110)
        }
        view.addSubview(lawyerSelectedButton)
        lawyerSelectedButton.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.leading.equalToSuperview().offset(36)
            $0.trailing.equalToSuperview().offset(-36)
            $0.bottom.equalToSuperview().offset(-30)
        }
	}
}
