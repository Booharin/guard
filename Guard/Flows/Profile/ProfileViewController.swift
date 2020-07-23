//
//  ProfileViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 23.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

protocol ProfileViewControllerProtocol {
	
}

class ProfileViewController<modelType: ViewModel>: UIViewController,
ProfileViewControllerProtocol where modelType.ViewType == ProfileViewControllerProtocol {
	
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
    }
}
