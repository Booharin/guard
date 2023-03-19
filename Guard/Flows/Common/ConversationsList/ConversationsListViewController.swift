//
//  ConversationsListViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 15.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

protocol ConversationsListViewControllerProtocol: ViewControllerProtocol {
	var greetingLabel: UILabel { get }
	var greetingDescriptionLabel: UILabel { get }
	var tableView: UITableView { get }
	var loadingView: AnimationView { get }
}

final class ConversationsListViewController<modelType: ConversationsListViewModel>:
	UIViewController,
	UITableViewDelegate,
	ConversationsListViewControllerProtocol {
	
	var greetingLabel = UILabel()
	var greetingDescriptionLabel = UILabel()
	var tableView = UITableView()
	private var gradientView: UIView?
	var loadingView = AnimationView()
	var viewModel: modelType
	var navController: UINavigationController? {
		self.navigationController
	}

	init(viewModel: modelType) {
		self.viewModel = viewModel
		self.viewModel.conversationsListSubject.onNext(())
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
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationController?.isNavigationBarHidden = false
		self.navigationItem.setHidesBackButton(true, animated:false)

		viewModel.currentConversationsListUpdateSubject.onNext(())
	}

	private func addViews() {
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

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return createHeaderView()
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 105
	}

	private func createHeaderView() -> UIView {
		let headerView = UIView()
		headerView.snp.makeConstraints {
			$0.height.equalTo(105)
			$0.width.equalTo(UIScreen.main.bounds.width)
		}
		headerView.addSubview(greetingLabel)
		greetingLabel.snp.makeConstraints {
			$0.height.equalTo(39)
			$0.width.equalTo(UIScreen.main.bounds.width)
			$0.top.equalToSuperview()
		}
		headerView.addSubview(greetingDescriptionLabel)
		greetingDescriptionLabel.snp.makeConstraints {
			$0.height.equalTo(28)
			$0.width.equalTo(UIScreen.main.bounds.width)
			$0.top.equalTo(greetingLabel.snp.bottom).offset(-2)
		}
		return headerView
	}
}
