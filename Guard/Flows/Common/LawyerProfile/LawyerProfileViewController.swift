//
//  LawyerProfileViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 10.12.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

protocol LawyerProfileViewControllerProtocol {
	
}

class LawyerProfileViewController<modelType: LawyerProfileViewModel>:
	UIViewController,
	LawyerProfileViewControllerProtocol {

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
	}
}
