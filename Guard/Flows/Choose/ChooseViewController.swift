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
	var lawyerEnterView: UIView { get }
	var clientEnterView: UIView { get }
}

/// Controller for user type choice
final class ChooseViewController<modelType: ViewModel>: UIViewController,
	ChooseViewControllerProtocol where modelType.ViewType == ChooseViewControllerProtocol {
	/// Pass to registration
	var toRegistration: ((UserType) -> (Void))?
	var titleLabel = UILabel()
	var lawyerEnterView = UIView()
	var clientEnterView = UIView()
	
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
		addViews()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.isNavigationBarHidden = true
	}
	
	private func addViews() {
		// ttile
		view.addSubview(titleLabel)
		titleLabel.snp.makeConstraints() {
			$0.top.equalToSuperview().offset(52)
			$0.centerX.equalToSuperview()
		}
		
		// lawyer enter button
		view.addSubview(lawyerEnterView)
		lawyerEnterView.snp.makeConstraints() {
			$0.height.equalTo(86)
			$0.centerY.equalToSuperview().offset(-68)
			$0.leading.equalToSuperview()
			$0.trailing.equalToSuperview()
		}
		let lawyerBorderView = UIView()
		lawyerBorderView.backgroundColor = Colors.mainColor
		lawyerEnterView.addSubview(lawyerBorderView)
		lawyerBorderView.snp.makeConstraints() {
			$0.leading.top.bottom.equalToSuperview()
			$0.width.equalTo(6)
		}
		let lawyerImageView = UIImageView(image: #imageLiteral(resourceName: "lawyer_mini_icn"))
		lawyerEnterView.addSubview(lawyerImageView)
		lawyerImageView.snp.makeConstraints() {
			$0.width.equalTo(18.94)
			$0.height.equalTo(17.42)
			$0.leading.equalToSuperview().offset(43.53)
			$0.top.equalToSuperview().offset(7.83)
		}

		// client enter button
		view.addSubview(clientEnterView)
		clientEnterView.snp.makeConstraints() {
			$0.height.equalTo(86)
			$0.centerY.equalToSuperview().offset(68)
			$0.leading.equalToSuperview()
			$0.trailing.equalToSuperview()
		}
		let clientBorderView = UIView()
		clientBorderView.backgroundColor = Colors.greenColor
		clientEnterView.addSubview(clientBorderView)
		clientBorderView.snp.makeConstraints() {
			$0.leading.top.bottom.equalToSuperview()
			$0.width.equalTo(6)
		}
		let clientImageView = UIImageView(image: #imageLiteral(resourceName: "client_mini_icn"))
		clientEnterView.addSubview(clientImageView)
		clientImageView.snp.makeConstraints() {
			$0.width.equalTo(16)
			$0.height.equalTo(16.43)
			$0.leading.equalToSuperview().offset(42)
			$0.top.equalToSuperview().offset(9.57)
		}
	}
}
