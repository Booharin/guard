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
}

/// Controller for selecting client issue
final class SelectIssueViewController<modelType: ViewModel>: UIViewController,
SelectIssueViewControllerProtocol where modelType.ViewType == SelectIssueViewControllerProtocol {

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
		view.backgroundColor = Colors.authBackground
		addViews()
    }
	
	private func addViews() {}
}
