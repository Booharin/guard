//
//  ClientProfileViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 20.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

protocol ClientProfileViewControllerProtocol {
	
}

final class ClientProfileViewController<modelType: ViewModel>: UIViewController,
ClientProfileViewControllerProtocol where modelType.ViewType == ClientProfileViewControllerProtocol {

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
		
	}
}
