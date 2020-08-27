//
//  SelectIssueViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 19.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
/// Protocol of controller for selecting client issue
protocol SelectIssueViewControllerProtocol {
	var tableView: UITableView { get }
	func update(with issues: [String])
}

/// Controller for selecting client issue
final class SelectIssueViewController<modelType: ViewModel>: UIViewController,
SelectIssueViewControllerProtocol where modelType.ViewType == SelectIssueViewControllerProtocol {
	
	var tableView = UITableView()
    var viewModel: modelType
	private var issues: [String]?
	
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
		addViews()
		self.navigationItem.setHidesBackButton(true, animated: false)
		title = "select_issue.title".localized
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.isNavigationBarHidden = false
	}
	
	private func addViews() {
		// table view
		tableView.register(SelectIssueTableViewCell.self, forCellReuseIdentifier: SelectIssueTableViewCell.reuseIdentifier)
		tableView.tableFooterView = UIView()
		tableView.backgroundColor = Colors.whiteColor
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 71
		view.addSubview(tableView)
		tableView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
 	}
	
	func update(with issues: [String]) {
		self.issues = issues
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
		
		if tableView.contentSize.height < tableView.frame.height {
            tableView.isScrollEnabled = false
		} else {
			tableView.isScrollEnabled = true
		}
	}
}
