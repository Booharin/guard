//
//  LawyerProfileViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 19.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class LawyerProfileViewModel:
	ViewModel,
	HasDependencies {

	typealias Dependencies =
		HasLocalStorageService &
		HasKeyChainService &
		HasClientNetworkService &
		HasCommonDataNetworkService
	lazy var di: Dependencies = DI.dependencies

	var view: LawyerProfileViewControlerProtcol!
	private let animationDuration = 0.15
	private var router: LawyerProfileRouterProtocol
	var lawyerImageSubject: PublishSubject<Any>?

	private var lawyerProfileFromList: UserProfile?
	var localLawyerProfile: UserProfile? {
		di.localStorageService.getCurrenClientProfile()
	}
	var currentProfile: UserProfile? {
		if let profile = lawyerProfileFromList {
			return profile
		} else {
			return localLawyerProfile
		}
	}
	private var issueLabels = [IssueLabel]()
	private var settings: SettingsModel? {
		di.localStorageService.getSettings(for: localLawyerProfile?.id ?? 0)
	}
	private var positiveReviewsCount = 0
	private var negativeReviewsCount = 0
	private var disposeBag = DisposeBag()

	init(lawyerProfileFromList: UserProfile?,
		 router: LawyerProfileRouterProtocol) {
		self.lawyerProfileFromList = lawyerProfileFromList
		self.router = router
	}

	func viewDidSet() {
		// swipe to go back
		view.view
			.rx
			.swipeGesture(.right)
			.when(.recognized)
			.subscribe(onNext: { [unowned self] _ in
				guard lawyerProfileFromList != nil else { return }
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
		view.backButtonView.isHidden = lawyerProfileFromList == nil

		// three dots button
		view.threedotsButton.setImage(#imageLiteral(resourceName: "three_dots_icn"), for: .normal)
		view.threedotsButton.rx
			.tap
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.threedotsButton.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.threedotsButton.alpha = 1
					})
				})
			})
			.subscribe(onNext: { [unowned self] _ in
				self.view.showActionSheet(toSettingsSubject: self.router.toSettingsSubject,
										  toEditSubject: self.router.toEditSubject)
			}).disposed(by: disposeBag)
		view.threedotsButton.isHidden = lawyerProfileFromList != nil

		// reviews
		view.reviewsTitleLabel.textColor = Colors.mainTextColor
		view.reviewsTitleLabel.font = SFUIDisplay.light.of(size: 18)
		view.reviewsTitleLabel.text = "profile.reviews".localized

		if let profile = lawyerProfileFromList {
			profile.reviewList?.forEach() {
				if $0.rating > 2 {
					positiveReviewsCount += 1
				} else {
					negativeReviewsCount += 1
				}
			}
		} else {
			di.localStorageService.getReviews().forEach {
				if $0.rating > 2 {
					positiveReviewsCount += 1
				} else {
					negativeReviewsCount += 1
				}
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
		view.ratingLabel.text = String(format: "%.1f", di.localStorageService.getCurrenClientProfile()?.averageRate ?? 0)
		view.ratingLabel.textColor = Colors.mainTextColor
		view.ratingLabel.font = SFUIDisplay.bold.of(size: 18)
	}

	func updateProfile() {
		// avatar
		if let image = di.localStorageService.getImage(with: "\(currentProfile?.id ?? 0)_profile_image.jpeg") {
			view.avatarImageView.image = image
		} else {
			view.avatarImageView.image = #imageLiteral(resourceName: "profile_icn").withRenderingMode(.alwaysTemplate)
			view.avatarImageView.tintColor = Colors.lightGreyColor
		}
		view.avatarImageView.clipsToBounds = true
		// title label
		view.titleNameLabel.textAlignment = .center
		view.titleNameLabel.textColor = Colors.mainTextColor
		view.titleNameLabel.font = Saira.bold.of(size: 22)
		view.titleNameLabel.text = currentProfile?.fullName
		// city label
		view.cityLabel.textAlignment = .center
		view.cityLabel.textColor = Colors.mainTextColor
		view.cityLabel.font = SFUIDisplay.light.of(size: 14)
		di.localStorageService.getRussianCities().forEach { city in
			if city.cityCode == currentProfile?.cityCode?.first {
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
		if let profile = lawyerProfileFromList {
			view.emailLabel.text = profile.email
		} else {
			view.emailLabel.text = self.di.keyChainService.getValue(for: Constants.KeyChainKeys.email)
		}
		view.emailLabel.isHidden = !(settings?.isEmailVisible ?? true)
		// phone label
		view.phoneLabel.textAlignment = .center
		view.phoneLabel.textColor = Colors.mainTextColor
		view.phoneLabel.font = SFUIDisplay.medium.of(size: 18)
		if let profile = lawyerProfileFromList {
			view.phoneLabel.text = profile.phoneNumber
		} else {
			view.phoneLabel.text = self.di.keyChainService.getValue(for: Constants.KeyChainKeys.phoneNumber)
		}
		view.phoneLabel.isHidden = !(settings?.isPhoneVisible ?? true)

		//MARK: - Update containerView with issues
		if currentProfile?.issueCodes?.isEmpty ?? true {
			let codes = currentProfile?.issueTypes?.map { $0.issueCode }
			updateIssuesContainerView(with: codes ?? [])
		} else {
			updateIssuesContainerView(with: [1, 3, 666])//currentProfile?.issueCodes ?? [])
		}

		lawyerImageSubject = PublishSubject<Any>()
		lawyerImageSubject?
			.asObservable()
			.flatMap ({ _ -> Observable<Bool> in
				guard self.lawyerProfileFromList == nil else {
					return .just(true)
				}
				if let image = self.di.localStorageService
					.getImage(with: "\(self.currentProfile?.id ?? 0)_profile_image.jpeg") {
					self.view.avatarImageView.image = image
					return .just(false)
				} else {
					return .just(true)
				}
			})
			.filter { result in
				return result == true
			}
			.flatMap { [unowned self] _ in
				self.di.clientNetworkService.getPhoto(profileId: currentProfile?.id ?? 0)
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				switch result {
					case .success(let data):
						self?.view.avatarImageView.image = UIImage(data: data)
					case .failure(let error):
						//TODO: - обработать ошибку
						print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)
	}

	private func updateIssuesContainerView(with issues: [Int]) {
		let screenWidth = UIScreen.main.bounds.width
		let containerWidth = screenWidth - 75
		var topOffset = 0
		var currentLineWidth: CGFloat = 0
		let interLabelOffset: CGFloat = 10
		var currentLabels = [UILabel]()

		issueLabels = []

		di.commonDataNetworkService.issueTypes?
			.compactMap { $0.subIssueTypeList }
			.reduce([], +)
			.filter { issues.contains($0.issueCode) }
			.forEach { issueType in
				print(issueType.title)
				print(issueType.issueCode)
				let label = IssueLabel(labelColor: Colors.issueLabelColor,
									   issueCode: issueType.issueCode)
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
							$0.leading.equalToSuperview().offset((containerWidth - labelWidth) / 2)
							//$0.leading.equalToSuperview().offset(currentLineWidth == 0 ? 0 : currentLineWidth + 10)
						} else if
							let firstLabel = currentLabels.first,
							let lastLabel = currentLabels.last {
							$0.leading.equalTo(lastLabel.snp.trailing).offset(interLabelOffset)
							firstLabel.snp.updateConstraints {
								$0.leading.equalToSuperview().offset((containerWidth - currentLineWidth) / 2)
							}
						}
					} else {
						currentLabels = []

						$0.leading.equalToSuperview().offset((containerWidth - labelWidth) / 2)
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
				if selectedIssuesSet.contains(issueType.issueCode) {
					label.selected(isOn: true)
				}
				issueLabels.append(label)
			}

		view.issuesContainerView.snp.updateConstraints {
			$0.height.equalTo(topOffset + 23)
		}
	}

	func removeBindings() {}
}