//
//  TabBarController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 22.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

		UITabBar.appearance().shadowImage = UIImage()
		UITabBar.appearance().backgroundImage = UIImage()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.isNavigationBarHidden = true
		self.navigationItem.setHidesBackButton(true, animated:false)
	}
}
