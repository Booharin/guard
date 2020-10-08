//
//  ClientProfileViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 20.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
import RxSwift

protocol ClientProfileViewControllerProtocol {
	var scrollView: UIScrollView { get }
	var threedotsButton: UIButton { get }

	var avatarImageView: UIImageView { get }
	var titleNameLabel: UILabel { get }
	var cityLabel: UILabel { get }
	var emailLabel: UILabel { get }
	var phoneLabel: UILabel { get }

	var reviewsTitleLabel: UILabel { get }
	var ratingTitleLabel: UILabel { get }
	var reviewsLabel: UILabel { get }
	var ratingLabel: UILabel { get }
	func showActionSheet(toSettingsSubject: PublishSubject<Any>)
}

final class ClientProfileViewController<modelType: ViewModel>: UIViewController,
ClientProfileViewControllerProtocol where modelType.ViewType == ClientProfileViewControllerProtocol {

	var scrollView = UIScrollView()
	var threedotsButton = UIButton()
	var avatarImageView = UIImageView()
	var titleNameLabel = UILabel()
	var cityLabel = UILabel()
	var emailLabel = UILabel()
	var phoneLabel = UILabel()

	var reviewsTitleLabel = UILabel()
	var ratingTitleLabel = UILabel()
	var reviewsLabel = UILabel()
	var ratingLabel = UILabel()

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
		navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
		navigationController?.navigationBar.isTranslucent = true
		self.navigationItem.setHidesBackButton(true, animated:false)
	}

	private func addViews() {
		// scroll view
		view.addSubview(scrollView)
		scrollView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
		// three dots button
		scrollView.addSubview(threedotsButton)
		threedotsButton.snp.makeConstraints {
			$0.width.height.equalTo(50)
			$0.top.equalToSuperview().offset(10)
			$0.trailing.equalToSuperview().offset(-20)
		}
		// avatar
		let avatarBackgroundView = UIView()
		scrollView.addSubview(avatarBackgroundView)
		avatarBackgroundView.snp.makeConstraints {
			$0.width.height.equalTo(158)
			$0.top.equalToSuperview().offset(40)
			$0.centerX.equalToSuperview()
		}
		avatarBackgroundView.layer.borderWidth = 0.5
		avatarBackgroundView.layer.borderColor = Colors.avatarCircle.cgColor
		avatarBackgroundView.layer.cornerRadius = 79
		
		let avatarInnerCircleView = UIView()
		avatarBackgroundView.addSubview(avatarInnerCircleView)
		avatarInnerCircleView.snp.makeConstraints {
			$0.width.height.equalTo(148)
			$0.center.equalToSuperview()
		}
		avatarInnerCircleView.layer.borderWidth = 2
		avatarInnerCircleView.layer.borderColor = Colors.avatarCircle.cgColor
		avatarInnerCircleView.layer.cornerRadius = 74
		avatarInnerCircleView.addSubview(avatarImageView)
		avatarImageView.snp.makeConstraints {
			$0.width.height.equalTo(136)
			$0.center.equalToSuperview()
		}
		avatarImageView.layer.cornerRadius = 68
		// title label
		scrollView.addSubview(titleNameLabel)
		titleNameLabel.snp.makeConstraints {
			$0.height.equalTo(35)
			$0.width.equalTo(UIScreen.main.bounds.width - 40)
			$0.top.equalTo(avatarBackgroundView.snp.bottom).offset(40)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
		}
		// city label
		scrollView.addSubview(cityLabel)
		cityLabel.snp.makeConstraints {
			$0.height.equalTo(20)
			$0.top.equalTo(titleNameLabel.snp.bottom).offset(5)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
		}
		// email label
		scrollView.addSubview(emailLabel)
		emailLabel.snp.makeConstraints {
			$0.height.equalTo(20)
			$0.top.equalTo(cityLabel.snp.bottom).offset(10)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
		}
		// phone label
		scrollView.addSubview(phoneLabel)
		phoneLabel.snp.makeConstraints {
			$0.height.equalTo(20)
			$0.top.equalTo(emailLabel.snp.bottom).offset(10)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
		}
	}

	// MARK: - Show action sheet
	func showActionSheet(toSettingsSubject: PublishSubject<Any>) {
		let alertController = UIAlertController(title: nil,
												message: nil,
												preferredStyle: .actionSheet)
		alertController.view.tintColor = Colors.mainTextColor
		// settings
		let settingsAction = UIAlertAction(title: "profile.action_sheet.settings".localized,
										   style: .default,
										   handler: { _ in
											alertController.dismiss(animated: true)
											toSettingsSubject.onNext(())
										   })
		alertController.addAction(settingsAction)
		// edit
		let editAction = UIAlertAction(title: "profile.action_sheet.edit".localized,
									   style: .default,
									   handler: { _ in
										alertController.dismiss(animated: true)
									   })
		alertController.addAction(editAction)
		let cancelAction = UIAlertAction(title: "alert.cancel".localized,
										 style: .cancel,
										 handler: { _ in
											alertController.dismiss(animated: true)
										 })
		alertController.addAction(cancelAction)
		self.present(alertController, animated: true)
	}
}
