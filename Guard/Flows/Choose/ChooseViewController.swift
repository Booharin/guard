//
//  ChooseViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 10.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
/// Protocol of controller for user type choice
protocol ChooseViewControllerProtocol {
	var toRegistration: ((UserType) -> (Void))? { get }
	var titleLabel: UILabel { get }
	var clientEnterButton: ConfirmButton { get }
	var lawyerEnterButton: ConfirmButton { get }
}

/// Controller for user type choice
final class ChooseViewController<modelType: ViewModel>: UIViewController,
	ChooseViewControllerProtocol where modelType.ViewType == ChooseViewControllerProtocol {
	/// Pass to registration
	var toRegistration: ((UserType) -> (Void))?
	var titleLabel = UILabel()
	var clientEnterButton = ConfirmButton(title: "choose.client.enter.button".localized)
	var lawyerEnterButton = ConfirmButton(title: "choose.lawyer.enter.button".localized)
	
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
		view.backgroundColor = Colors.authBackground
		addViews()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.isNavigationBarHidden = true
	}
	
	private func addViews() {
		
		// client enter button
		view.addSubview(clientEnterButton)
		clientEnterButton.snp.makeConstraints() {
			$0.height.equalTo(50)
			$0.centerX.equalToSuperview()
			$0.centerY.equalToSuperview().offset(50)
			$0.leading.equalToSuperview().offset(30)
			$0.trailing.equalToSuperview().offset(-30)
		}
		
		// lawyer enter button
		view.addSubview(lawyerEnterButton)
		lawyerEnterButton.snp.makeConstraints() {
			$0.height.equalTo(50)
			$0.centerX.equalToSuperview()
			$0.centerY.equalToSuperview().offset(-50)
			$0.leading.equalToSuperview().offset(30)
			$0.trailing.equalToSuperview().offset(-30)
		}
		
		// ttile
		view.addSubview(titleLabel)
		titleLabel.snp.makeConstraints() {
			$0.bottom.equalTo(lawyerEnterButton.snp.top).offset(-50)
			$0.centerX.equalToSuperview()
		}
	}
}
