//
//  ChooseViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 10.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
/// Controller for user type choice
final class ChooseViewController: UIViewController {
	/// Pass to authorization
	var toAuth: ((UserType) -> (Void))?
	private var clientEnterButton = ConfirmButton(title: "choose.client.enter.button".localized)
	private var lawyerEnterButton = ConfirmButton(title: "choose.lawyer.enter.button".localized)

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = true
		view.backgroundColor = Colors.authBackground
		
		addViews()
    }
	
	private func addViews() {
		// client enter button
		clientEnterButton.addTarget(self,
							  action: #selector(didClientTap),
							  for: .touchUpInside)
		view.addSubview(clientEnterButton)
		clientEnterButton.snp.makeConstraints() {
			$0.height.equalTo(50)
			$0.centerX.equalToSuperview()
			$0.centerY.equalToSuperview().offset(50)
			$0.leading.equalToSuperview().offset(30)
			$0.trailing.equalToSuperview().offset(-30)
		}
		
		// lawyer enter button
		lawyerEnterButton.addTarget(self,
							  action: #selector(didLawyerTap),
							  for: .touchUpInside)
		view.addSubview(lawyerEnterButton)
		lawyerEnterButton.snp.makeConstraints() {
			$0.height.equalTo(50)
			$0.centerX.equalToSuperview()
			$0.centerY.equalToSuperview().offset(-50)
			$0.leading.equalToSuperview().offset(30)
			$0.trailing.equalToSuperview().offset(-30)
		}
	}
	
	@objc func didClientTap() {
		clientEnterButton.isEnabled = false
		lawyerEnterButton.isEnabled = false
		clientEnterButton.animateBackground()
		
		toAuth?(.client)
	}
	
	@objc func didLawyerTap() {
		clientEnterButton.isEnabled = false
		lawyerEnterButton.isEnabled = false
		lawyerEnterButton.animateBackground()
		
		toAuth?(.lawyer)
	}
}
