//
//  SettingsViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 23.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
import RxSwift

protocol SettingsViewControllerProtocol: ViewControllerProtocol {
	var backButtonView: BackButtonView { get }
	var titleView: UIView { get }
	var titleLabel: UILabel { get }
	var tableView: UITableView { get }
	func showActionSheet(toAuthSubject: PublishSubject<Any>)
}

class SettingsViewController<modelType: SettingsViewModel>: UIViewController,
	UITableViewDelegate,
	SettingsViewControllerProtocol {

	var backButtonView = BackButtonView()
	var titleView = UIView()
	var titleLabel = UILabel()
	var tableView = UITableView()
	private var gradientView: UIView?
	var navController: UINavigationController? {
		self.navigationController
	}

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
		// table view
		tableView.register(SelectIssueTableViewCell.self,
						   forCellReuseIdentifier: SelectIssueTableViewCell.reuseIdentifier)
		tableView.tableFooterView = UIView()
		tableView.backgroundColor = Colors.whiteColor
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 62
		tableView.separatorStyle = .none
		tableView.delegate = self
		view.addSubview(tableView)
		tableView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
	}

	// MARK: - Show action sheet
	func showActionSheet(toAuthSubject: PublishSubject<Any>) {
		let alertController = UIAlertController(title: "logout.alert.title".localized,
												message: "logout.alert.message".localized,
												preferredStyle: .actionSheet)
		alertController.view.tintColor = Colors.mainTextColor
		// exit
		let exitAction = UIAlertAction(title: "logout.alert.ok".localized,
										   style: .destructive,
										   handler: { _ in
											alertController.dismiss(animated: true)
											toAuthSubject.onNext(())
										   })
		alertController.addAction(exitAction)

		let cancelAction = UIAlertAction(title: "alert.cancel".localized,
										 style: .cancel,
										 handler: { _ in
											alertController.dismiss(animated: true)
										 })
		alertController.addAction(cancelAction)
		self.present(alertController, animated: true)
	}
}
