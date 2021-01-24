//
//  LawyerProfileViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 19.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit
import RxSwift

protocol LawyerProfileViewControlerProtcol: class, ViewControllerProtocol {
	var backButtonView: BackButtonView { get }
	var scrollView: UIScrollView { get }
	var threedotsButton: UIButton { get }

	var avatarImageView: UIImageView { get }
	var titleNameLabel: UILabel { get }
	var cityLabel: UILabel { get }
	var emailLabel: UILabel { get }
	var phoneLabel: UILabel { get }

	var issuesContainerView: UIView { get }

	var reviewsTitleLabel: UILabel { get }
	var ratingTitleLabel: UILabel { get }
	var reviewsPositiveLabel: UILabel { get }
	var reviewsNegativeLabel: UILabel { get }
	var ratingLabel: UILabel { get }
	var chatWithLawyerButton: ConfirmButton { get }
	func showActionSheet(toSettingsSubject: PublishSubject<Any>,
						 toEditSubject: PublishSubject<UserProfile>)
}

final class LawyerProfileViewController<modelType: LawyerProfileViewModel>:
	UIViewController,
	LawyerProfileViewControlerProtcol {

	var backButtonView = BackButtonView()
	var scrollView = UIScrollView()
	var threedotsButton = UIButton()
	var avatarImageView = UIImageView()
	var titleNameLabel = UILabel()
	var cityLabel = UILabel()
	var emailLabel = UILabel()
	var phoneLabel = UILabel()

	var issuesContainerView = UIView()

	var reviewsTitleLabel = UILabel()
	var reviewsPositiveLabel = UILabel()
	var reviewsNegativeLabel = UILabel()
	var ratingTitleLabel = UILabel()
	var ratingLabel = UILabel()
	var chatWithLawyerButton = ConfirmButton(title: "profile.chat.button.titile".localized.uppercased(),
											 backgroundColor: Colors.greenColor)

	var viewModel: modelType
	var navController: UINavigationController? {
		self.navigationController
	}

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
		setNavigationBar()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.isNavigationBarHidden = false
		self.navigationItem.setHidesBackButton(true, animated:false)

		viewModel.updateProfile()
		viewModel.lawyerImageSubject?.onNext(())
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
	}

	private func setNavigationBar() {
		let leftBarButtonItem = UIBarButtonItem(customView: backButtonView)
		self.navigationItem.leftBarButtonItem = leftBarButtonItem
		let rightBarButtonItem = UIBarButtonItem(customView: threedotsButton)
		self.navigationItem.rightBarButtonItem = rightBarButtonItem
	}

	private func addViews() {
		// scroll view
		view.addSubview(scrollView)
		scrollView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
		// avatar
		let avatarBackgroundView = UIView()
		scrollView.addSubview(avatarBackgroundView)
		avatarBackgroundView.snp.makeConstraints {
			$0.width.height.equalTo(158)
			$0.top.equalToSuperview()
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
		scrollView.addSubview(issuesContainerView)
		issuesContainerView.snp.makeConstraints {
			$0.top.equalTo(phoneLabel.snp.bottom).offset(26)
			$0.leading.equalToSuperview().offset(35)
			$0.trailing.equalToSuperview().offset(-35)
			$0.height.equalTo(23)
		}
		// reviews and rating
		// vertical separator
		let verticalSeparatorView = UIView()
		verticalSeparatorView.backgroundColor = Colors.verticalSeparator
		scrollView.addSubview(verticalSeparatorView)
		verticalSeparatorView.snp.makeConstraints {
			$0.top.equalTo(issuesContainerView.snp.bottom).offset(31)
			$0.centerX.equalToSuperview()
			$0.height.equalTo(61)
			$0.width.equalTo(1)
		}
		// reviews title
		scrollView.addSubview(reviewsTitleLabel)
		reviewsTitleLabel.snp.makeConstraints {
			$0.top.equalTo(verticalSeparatorView.snp.top)
			$0.trailing.equalTo(verticalSeparatorView.snp.leading).offset(-37)
		}
		// vertical reviews separator
		let verticalReviewsSeparatorView = UIView()
		verticalReviewsSeparatorView.backgroundColor = Colors.verticalSeparator
		scrollView.addSubview(verticalReviewsSeparatorView)
		verticalReviewsSeparatorView.snp.makeConstraints {
			$0.top.equalTo(reviewsTitleLabel.snp.bottom).offset(17)
			$0.height.equalTo(20)
			$0.width.equalTo(1)
			$0.centerX.equalTo(reviewsTitleLabel.snp.centerX)
		}
		// positive review
		scrollView.addSubview(reviewsPositiveLabel)
		reviewsPositiveLabel.snp.makeConstraints {
			$0.centerY.equalTo(verticalReviewsSeparatorView.snp.centerY)
			$0.trailing.equalTo(verticalReviewsSeparatorView.snp.leading).offset(-9)
		}
		// negative review
		scrollView.addSubview(reviewsNegativeLabel)
		reviewsNegativeLabel.snp.makeConstraints {
			$0.centerY.equalTo(verticalReviewsSeparatorView.snp.centerY)
			$0.leading.equalTo(verticalReviewsSeparatorView.snp.trailing).offset(9)
		}
		// rating title
		scrollView.addSubview(ratingTitleLabel)
		ratingTitleLabel.snp.makeConstraints {
			$0.top.equalTo(verticalSeparatorView.snp.top)
			$0.leading.equalTo(verticalSeparatorView.snp.trailing).offset(37)
		}
		let ratingView = UIView()
		scrollView.addSubview(ratingView)
		ratingView.snp.makeConstraints {
			$0.top.equalTo(ratingTitleLabel.snp.bottom).offset(17)
			$0.centerX.equalTo(ratingTitleLabel.snp.centerX)
		}
		// star image
		let starImageView = UIImageView(image: #imageLiteral(resourceName: "star_icn"))
		ratingView.addSubview(starImageView)
		starImageView.snp.makeConstraints {
			$0.height.width.equalTo(16)
			$0.leading.equalToSuperview()
			$0.centerY.equalToSuperview()
		}
		ratingView.addSubview(ratingLabel)
		ratingLabel.snp.makeConstraints {
			$0.height.equalTo(21)
			$0.top.trailing.bottom.equalToSuperview()
			$0.leading.equalTo(starImageView.snp.trailing).offset(7)
		}
		// chat with lawyer button
		scrollView.addSubview(chatWithLawyerButton)
		chatWithLawyerButton.setImage(#imageLiteral(resourceName: "tab_chat_icn").withRenderingMode(.alwaysTemplate),
									  for: .normal)
		chatWithLawyerButton.imageView?.tintColor = Colors.whiteColor
		chatWithLawyerButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 0)
		chatWithLawyerButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
		chatWithLawyerButton.snp.makeConstraints {
			$0.top.equalTo(verticalReviewsSeparatorView.snp.bottom).offset(50)
			$0.width.equalTo(142)
			$0.height.equalTo(49)
			$0.centerX.equalToSuperview()
		}
	}

	// MARK: - Show action sheet
	func showActionSheet(toSettingsSubject: PublishSubject<Any>,
						 toEditSubject: PublishSubject<UserProfile>) {
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
										guard let userProfile = self.viewModel.currentProfile else { return }
										toEditSubject.onNext(userProfile)
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
