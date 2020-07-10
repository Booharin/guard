//
//  MainViewController.swift
//  Wheels
//
//  Created by Alexandr Bukharin on 23.06.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
import SnapKit

final class MainViewController: UIViewController {
	
	var coordinator: MainCoordinator?
	var toCameraViewController: (() -> (Void))?
	private var enterButton = ConfirmButton(title: "main.enter.title".localized)

    override func viewDidLoad() {
        super.viewDidLoad()

		navigationController?.isNavigationBarHidden = true
		view.backgroundColor = Colors.mainBackground
		
		addViews()
    }
	
	private func addViews() {
		// enter button
		enterButton.addTarget(self,
							  action: #selector(didEnterTap),
							  for: .touchUpInside)
		view.addSubview(enterButton)
		enterButton.snp.makeConstraints() {
			$0.height.equalTo(50)
			$0.centerX.equalToSuperview()
			$0.centerY.equalToSuperview()
			$0.leading.equalToSuperview().offset(30)
			$0.trailing.equalToSuperview().offset(-30)
		}
	}
	
	@objc func didEnterTap() {
		view.endEditing(true)
		enterButton.isEnabled = false
		enterButton.animateBackground()
		
		toCameraViewController?()
	}
}
