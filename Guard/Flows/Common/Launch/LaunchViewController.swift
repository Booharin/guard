//
//  LaunchViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 21.07.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit

final class LaunchViewController: UIViewController {

	var loadingView = LottieAnimationView()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		// loading view
		view.addSubview(loadingView)
		loadingView.snp.makeConstraints {
			$0.center.equalToSuperview()
			$0.width.height.equalTo(300)
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationController?.setNavigationBarHidden(true, animated: true)
		self.navigationItem.setHidesBackButton(true, animated:false)
	}
}
