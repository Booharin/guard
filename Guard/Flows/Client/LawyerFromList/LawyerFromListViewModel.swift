//
//  LawyerFromListViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 27.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class LawyerFromListViewModel:
	ViewModel,
	HasDependencies {

	typealias Dependencies =
		HasLocalStorageService &
		HasClientNetworkService &
		HasCommonDataNetworkService
	lazy var di: Dependencies = DI.dependencies

	var view: LawyerFromListViewControllerProtcol!
	private let animationDuration = 0.15
	private var router: LawyerFromListRouterProtocol
	var lawyerImageSubject: PublishSubject<Any>?
	private let chatWithLawyerSubject = PublishSubject<Any>()
	private let settingsLawyerSubject = PublishSubject<Any>()

	private let lawyerProfile: UserProfile
	private var lawyerSettings: SettingsModel?
	private let isFromChat: Bool

	private var positiveReviewsCount = 0
	private var negativeReviewsCount = 0
	private var disposeBag = DisposeBag()

	init(lawyerProfile: UserProfile,
		 isFromChat: Bool,
		 router: LawyerFromListRouterProtocol) {
		self.lawyerProfile = lawyerProfile
		self.lawyerSettings = lawyerProfile.settings
		self.isFromChat = isFromChat
		self.router = router
	}

	func viewDidSet() {
		// swipe to go back
		view.view
			.rx
			.swipeGesture(.right)
			.when(.recognized)
			.subscribe(onNext: { [unowned self] _ in
				self.view.navController?.popViewController(animated: true)
			}).disposed(by: disposeBag)

		// back button
		view.backButtonView
			.rx
			.tapGesture()
			.when(.recognized)
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.backButtonView.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.backButtonView.alpha = 1
					})
				})
			})
			.subscribe(onNext: { [weak self] _ in
				self?.view.navController?.popViewController(animated: true)
			}).disposed(by: disposeBag)

		// avatar
		view.avatarImageView.clipsToBounds = true

		view.phoneLabel
			.rx
			.tapGesture()
			.when(.recognized)
			.subscribe(onNext: { [weak self] _ in
				guard
					let phone = self?.view.phoneLabel.text,
					let url = URL(string: "tel://\(phone)"),
					UIApplication.shared.canOpenURL(url) else { return }
				UIApplication.shared.open(url)
			}).disposed(by: disposeBag)
		view.phoneLabel.isHidden = true

		view.emailLabel
			.rx
			.tapGesture()
			.when(.recognized)
			.subscribe(onNext: { [weak self] _ in
				guard
					let email = self?.view.emailLabel.text,
					let url = URL(string: "mailto:\(email)"),
					UIApplication.shared.canOpenURL(url) else { return }
				UIApplication.shared.open(url)
			}).disposed(by: disposeBag)
		view.emailLabel.isHidden = true

		// reviews
		view.reviewsTitleLabel.textColor = Colors.mainTextColor
		view.reviewsTitleLabel.font = SFUIDisplay.light.of(size: 18)
		view.reviewsTitleLabel.text = "profile.reviews".localized

		view.reviewsView
			.rx
			.tapGesture()
			.when(.recognized)
			.subscribe(onNext: { [weak self] _ in
				self?.router.passageToReviewsList(isMyReviews: false,
												  usertId: self?.lawyerProfile.id ?? 0,
												  reviews: self?.lawyerProfile.reviewList ?? [])
			}).disposed(by: disposeBag)

		// MARK: - Reviews
		lawyerProfile.reviewList?.forEach() {
			if $0.rating > 2 {
				positiveReviewsCount += 1
			} else {
				negativeReviewsCount += 1
			}
		}

		// positive review
		view.reviewsPositiveLabel.textColor = Colors.greenColor
		view.reviewsPositiveLabel.font = SFUIDisplay.bold.of(size: 18)
		view.reviewsPositiveLabel.text = "+\(positiveReviewsCount)"
		// negative review
		view.reviewsNegativeLabel.textColor = Colors.negativeReview
		view.reviewsNegativeLabel.font = SFUIDisplay.bold.of(size: 18)
		view.reviewsNegativeLabel.text = "-\(negativeReviewsCount)"
		// rating title
		view.ratingTitleLabel.textColor = Colors.mainTextColor
		view.ratingTitleLabel.font = SFUIDisplay.light.of(size: 18)
		view.ratingTitleLabel.text = "profile.rating".localized
		// rating
		view.ratingLabel.text = String(format: "%.1f", lawyerProfile.averageRate ?? 0)
		view.ratingLabel.textColor = Colors.mainTextColor
		view.ratingLabel.font = SFUIDisplay.bold.of(size: 18)

		settingsLawyerSubject
			.asObservable()
			.flatMap { [unowned self] _ in
				self.di.clientNetworkService.getSettings(profileId: lawyerProfile.id)
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				switch result {
				case .success(let settings):
					self?.lawyerSettings = settings
					self?.updateVisability()
				case .failure(let error):
					//TODO: - обработать ошибку
					print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)
		settingsLawyerSubject.onNext(())

		lawyerImageSubject = PublishSubject<Any>()
		lawyerImageSubject?
			.asObservable()
			.flatMap { [unowned self] _ in
				self.di.clientNetworkService.getPhoto(profileId: lawyerProfile.id)
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				switch result {
					case .success(let data):
						self?.view.avatarImageView.image = UIImage(data: data)
					case .failure(let error):
						self?.view.avatarImageView.image = #imageLiteral(resourceName: "profile_icn").withRenderingMode(.alwaysTemplate)
						self?.view.avatarImageView.tintColor = Colors.lightGreyColor
						print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)

		view.chatWithLawyerButton.isHidden = true
		view.chatWithLawyerButton
			.rx
			.tap
			.subscribe(onNext: { [weak self] _ in
				self?.view.tabBarViewController?.selectedIndex = 2

				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					guard
						let navigationController = self?.view.tabBarViewController?.viewControllers?[2] as? UINavigationController,
						let vc = navigationController.viewControllers.first as? ConversationsListViewController,
						let profile = self?.lawyerProfile else { return }

					let newConversation = ChatConversation(id: -1,
														   dateCreated: "",
														   userId: profile.id,
														   lastMessage: "",
														   appealId: nil,
														   userFirstName: profile.firstName,
														   userLastName: profile.lastName,
														   userPhoto: profile.photo)

					vc.viewModel.toChatWithLawyer?.onNext(newConversation)
				}
			}).disposed(by: disposeBag)
	}

	func updateProfile() {
		// title label
		view.titleNameLabel.textAlignment = .center
		view.titleNameLabel.textColor = Colors.mainTextColor
		view.titleNameLabel.font = Saira.bold.of(size: 22)
		view.titleNameLabel.text = lawyerProfile.fullName
		// city label
		view.cityLabel.textAlignment = .center
		view.cityLabel.textColor = Colors.mainTextColor
		view.cityLabel.font = SFUIDisplay.light.of(size: 14)
		di.localStorageService.getRussianCities().forEach { city in
			if city.cityCode == lawyerProfile.cityCode?.first {
				if let locale = Locale.current.languageCode, locale == "ru" {
					view.cityLabel.text = "🇷🇺 Россия, \(city.title)"
				} else {
					view.cityLabel.text = "🇷🇺 Russia, \(city.titleEn)"
				}
			}
		}
		// email label
		view.emailLabel.textAlignment = .center
		view.emailLabel.textColor = Colors.mainTextColor
		view.emailLabel.font = SFUIDisplay.regular.of(size: 15)
		view.emailLabel.text = lawyerProfile.email

		// phone label
		view.phoneLabel.textAlignment = .center
		view.phoneLabel.textColor = Colors.mainTextColor
		view.phoneLabel.font = SFUIDisplay.medium.of(size: 18)
		view.phoneLabel.text = lawyerProfile.phoneNumber

		//MARK: - Update containerView with issues
		updateIssuesContainerView(with: lawyerProfile.subIssueTypes?.compactMap { $0.subIssueCode } ?? [])

		updateVisability()
	}

	private func updateVisability() {
		guard let settings = lawyerSettings else { return }
		view.emailLabel.isHidden = !settings.isEmailVisible
		view.phoneLabel.isHidden = !settings.isPhoneVisible
		if isFromChat == false {
			view.chatWithLawyerButton.isHidden = !settings.isChatEnabled
		}
	}

	private func updateIssuesContainerView(with issues: [Int]) {
		let screenWidth = UIScreen.main.bounds.width
		let containerWidth = screenWidth - 75
		var topOffset = 0
		var currentLineWidth: CGFloat = 0
		let interLabelOffset: CGFloat = 10
		var currentLabels = [UILabel]()

		view.issuesContainerView.subviews.forEach {
			$0.removeFromSuperview()
		}

		di.commonDataNetworkService.issueTypes?
			.compactMap { $0.subIssueTypeList }
			.reduce([], +)
			.filter { issues.contains($0.subIssueCode ?? 0) }
			.forEach { issueType in
				print(issueType.title)
				print(issueType.issueCode)
				let label = IssueLabel(labelColor: Colors.issueLabelColor,
									   subIssueCode: issueType.subIssueCode ?? 0,
									   isSelectable: false)
				label.text = issueType.title
				// calculate correct size of label
				let labelWidth = issueType.title.width(withConstrainedHeight: 23,
												font: SFUIDisplay.medium.of(size: 12)) + 20
				let labelHeight = issueType.title.height(withConstrainedWidth: containerWidth,
												  font: SFUIDisplay.medium.of(size: 12)) + 9
				view.issuesContainerView.addSubview(label)
				label.snp.makeConstraints {
					if currentLineWidth + labelWidth + 10 < containerWidth {
						currentLineWidth += labelWidth
						if currentLabels.last == nil {
							let correctOffset = labelWidth >= containerWidth ?
								0 : (containerWidth - labelWidth) / 2
							$0.leading.equalToSuperview().offset(correctOffset)
						} else if
							let firstLabel = currentLabels.first,
							let lastLabel = currentLabels.last {
							$0.leading.equalTo(lastLabel.snp.trailing).offset(interLabelOffset)
							firstLabel.snp.updateConstraints {
								let correctOffset = currentLineWidth >= containerWidth ?
									0 : (containerWidth - currentLineWidth) / 2
								$0.leading.equalToSuperview().offset(correctOffset)
							}
						}
					} else {
						currentLabels = []

						let correctOffset = labelWidth >= containerWidth ?
							0 : (containerWidth - labelWidth) / 2

						$0.leading.equalToSuperview().offset(correctOffset)
						topOffset += (10 + Int(labelHeight))
						currentLineWidth = labelWidth
					}

					currentLabels.append(label)

					$0.top.equalToSuperview().offset(topOffset)
					$0.width.equalTo(labelWidth > containerWidth ? containerWidth : labelWidth)
					$0.height.equalTo(labelHeight)
				}
				// check if there issues
				let selectedIssuesSet = Set(issues)
				if selectedIssuesSet.contains(issueType.subIssueCode ?? 0) {
					label.selected(isOn: true)
				}
			}

		view.issuesContainerView.snp.updateConstraints {
			$0.height.equalTo(topOffset + 23)
		}
	}

	func removeBindings() {}
}
