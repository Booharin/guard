//
//  NavigationController.swift
//  Wheels
//
//  Created by Alexandr Bukharin on 23.06.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

final class NavigationController: UINavigationController {
	override func viewDidLoad() {
		super.viewDidLoad()

		// translucent navbar
		//navigationBar.setBackgroundImage(UIImage(), for: .default)
		navigationBar.shadowImage = UIImage()
		navigationBar.isTranslucent = false
		navigationBar.backgroundColor = .clear
		navigationBar.barTintColor = Colors.whiteColor
		navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Colors.whiteColor]
	}
}
