//
//  LawyerListViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 03.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

protocol LawyerListViewControllerProtocol {
	var filterButtonView: FiltetButtonView { get }
}

class LawyerListViewController<modelType: ViewModel>: UIViewController,
LawyerListViewControllerProtocol where modelType.ViewType == LawyerListViewControllerProtocol {

	var filterButtonView = FiltetButtonView()
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
	
	func setNavigationBar() {
		let rightBarButtonItem = UIBarButtonItem(customView: filterButtonView)
		self.navigationItem.rightBarButtonItem = rightBarButtonItem
	}
	
	private func addViews() {
		
	}
}
