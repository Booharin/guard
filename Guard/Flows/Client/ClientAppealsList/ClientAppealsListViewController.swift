//
//  ClientAppealsListViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 09.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

protocol ClientAppealsListViewControllerProtocol {
    var addButtonView: AddButtonView { get }
    var titleView: UIView { get }
    var titleLabel: UILabel { get }
    var tableView: UITableView { get }
}

final class ClientAppealsListViewController<modelType: ViewModel>: UIViewController, UITableViewDelegate,
ClientAppealsListViewControllerProtocol where modelType.ViewType == ClientAppealsListViewControllerProtocol {
    var addButtonView = AddButtonView()
    var titleView = UIView()
    var titleLabel = UILabel()
    var tableView = UITableView()

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
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationItem.setHidesBackButton(true, animated:false)
    }
    
    func setNavigationBar() {
        let rightBarButtonItem = UIBarButtonItem(customView: addButtonView)
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
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
    }
}
