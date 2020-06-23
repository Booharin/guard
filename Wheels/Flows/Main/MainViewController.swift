//
//  MainViewController.swift
//  Wheels
//
//  Created by Alexandr Bukharin on 23.06.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
	
	var coordinator: MainCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()

		navigationController?.isNavigationBarHidden = true
		view.backgroundColor = .red
    }
}
