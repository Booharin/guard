//
//  ReviewsListViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 26.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit

protocol ReviewsListViewControllerProtocol: ViewControllerProtocol {
	var backButtonView: BackButtonView { get }
	var addButtonView: AddButtonView { get }
	var titleView: UIView { get }
	var titleLabel: UILabel { get }
	var tableView: UITableView { get }
	var loadingView: AnimationView { get }
}

class ReviewsListViewController<modelType: ReviewsListViewModel>:
	UIViewController,
	UITableViewDelegate,
	ReviewsListViewControllerProtocol {
	
	var backButtonView = BackButtonView()
	var addButtonView = AddButtonView()
	var titleView = UIView()
	var titleLabel = UILabel()
	var tableView = UITableView()
	private var gradientView: UIView?
	var loadingView = AnimationView()
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

	private func setNavigationBar() {
		let leftBarButtonItem = UIBarButtonItem(customView: backButtonView)
		let rightBarButtonItem = UIBarButtonItem(customView: addButtonView)
		self.navigationItem.leftBarButtonItem = leftBarButtonItem
		self.navigationItem.rightBarButtonItem = rightBarButtonItem
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
		tableView.register(ConversationCell.self,
						   forCellReuseIdentifier: ConversationCell.reuseIdentifier)
		tableView.tableFooterView = UIView()
		tableView.backgroundColor = Colors.whiteColor
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 72
		tableView.separatorStyle = .none
		tableView.delegate = self
		view.addSubview(tableView)
		tableView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
		// loading view
		view.addSubview(loadingView)
		loadingView.snp.makeConstraints {
			$0.center.equalToSuperview()
			$0.width.height.equalTo(300)
		}
	}
}
