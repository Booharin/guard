//
//  ClientsListViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 12.09.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit

protocol ClientsListViewControllerProtocol: class, ViewControllerProtocol {
    var tableView: UITableView { get }
    var loadingView: LottieAnimationView { get }
}

final class ClientsListViewController<modelType: ClientsListViewModel>:
    UIViewController,
    UITableViewDelegate,
    ClientsListViewControllerProtocol {

    var viewModel: modelType

    var titleView = UIView()
    var titleLabel = UILabel()
    var tableView = UITableView()
    var loadingView = LottieAnimationView()
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.isNavigationBarHidden = false
        self.navigationItem.setHidesBackButton(true, animated:false)
    }

    private func addViews() {
        
        // table view
        tableView.register(SelectIssueTableViewCell.self,
                           forCellReuseIdentifier: SelectIssueTableViewCell.reuseIdentifier)
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

