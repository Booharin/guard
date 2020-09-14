//
//  ChatViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 14.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

protocol ChatViewControllerProtocol: ViewControllerProtocol {
	var tableView: UITableView { get }
}

final class ChatViewController<modelType: ChatViewModel>: UIViewController, UITextViewDelegate,
ChatViewControllerProtocol where modelType.ViewType == ChatViewControllerProtocol {
	
	var tableView = UITableView()
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
	
	private func setNavigationBar() {

	}
	
	private func addViews() {
		
	}
}
