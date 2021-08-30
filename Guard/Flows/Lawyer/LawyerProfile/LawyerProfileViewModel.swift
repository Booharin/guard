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
		HasLawyersNetworkService &
		HasCommonDataNetworkService
	lazy var di: Dependencies = DI.dependencies

	var view: LawyerProfileViewControlerProtcol!
	private let animationDuration = 0.15
	private var router: LawyerProfileRouterProtocol
	var lawyerImageSubject: PublishSubject<Any>?
	private let settingsLawyerSubject = PublishSubject<Any>()

	var lawyerProfile: UserProfile? {
		di.localStorageService.getCurrenClientProfile()
	}

	private var lawyerSettings: SettingsModel?

	let reviewsListSubject = PublishSubject<Any>()
	private var reviews = [UserReview]()

	private var positiveReviewsCount = 0
	private var negativeReviewsCount = 0
	private var disposeBag = DisposeBag()

	init(router: LawyerProfileRouterProtocol) {
		self.router = router
	}

	func viewDidSet() {
		// three dots button
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

		// avatar
		view.avatarImageView.clipsToBounds = true
		if let image = self.di.localStorageService.getImage(with: "\(self.lawyerProfile?.id ?? 0)_profile_image.jpeg") {
			view.avatarImageView.image = image
		} else {
			view.avatarImageView.image = #imageLiteral(resourceName: "profile_icn").withRenderingMode(.alwaysTemplate)
			view.avatarImageView.tintColor = Colors.lightGreyColor
		}

		view.phoneLabel.isHidden = true
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
				guard let reviewsListSubject = self?.reviewsListSubject else { return }
				self?.router.passageToReviewsList(isMyReviews: true,
												  reviewsUpdateSubject: reviewsListSubject,
												  usertId: self?.lawyerProfile?.id ?? 0,
												  reviews: self?.reviews ?? [])
			}).disposed(by: disposeBag)

		// positive review
		view.reviewsPositiveLabel.textColor = Colors.greenColor
		view.reviewsPositiveLabel.font = SFUIDisplay.bold.of(size: 18)
		// negative review
		view.reviewsNegativeLabel.textColor = Colors.negativeReview
		view.reviewsNegativeLabel.font = SFUIDisplay.bold.of(size: 18)
		// rating title
		view.ratingTitleLabel.textColor = Colors.mainTextColor
		view.ratingTitleLabel.font = SFUIDisplay.light.of(size: 18)
		view.ratingTitleLabel.text = "profile.rating".localized
		// rating
		view.ratingLabel.text = String(format: "%.1f", lawyerProfile?.averageRate ?? 0)
		view.ratingLabel.textColor = Colors.mainTextColor
		view.ratingLabel.font = SFUIDisplay.bold.of(size: 18)

		settingsLawyerSubject
			.asObservable()
			.do(onNext: { [unowned self] _ in
				guard let _ = self.di.localStorageService.getSettings(for: self.lawyerProfile?.id ?? 0) else {
					return
				}
				self.updateVisability()
			})
			.flatMap { [unowned self] _ in
				self.di.clientNetworkService.getSettings(profileId: self.lawyerProfile?.id ?? 0)
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				switch result {
					case .success(let settings):
						self?.updateVisability(with: settings)
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
				self.di.clientNetworkService.getPhoto(profileId: lawyerProfile?.id ?? 0)
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				switch result {
					case .success(let data):
						self?.view.avatarImageView.image = UIImage(data: data)
					case .failure(let error):
						print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)

		view.issuesStackView.axis = .vertical
		view.issuesStackView.distribution = .fill
		view.issuesStackView.alignment = .center
		view.issuesStackView.spacing = 10

		reviewsListSubject
			.asObservable()
			.flatMap { [unowned self] _ in
				self.di.lawyersNetworkService.getReviews(for: lawyerProfile?.id ?? 0,
														 page: 0,
														 pageSize: 10000)
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				switch result {
				case .success(let reviews):
					self?.reviews = reviews
					self?.positiveReviewsCount = 0
					self?.negativeReviewsCount = 0

					reviews.forEach() {
						if $0.rating > 2 {
							self?.positiveReviewsCount += 1
						} else {
							self?.negativeReviewsCount += 1
						}
					}
					self?.view.reviewsPositiveLabel.text = "+\(self?.positiveReviewsCount ?? 0)"
					self?.view.reviewsNegativeLabel.text = "-\(self?.negativeReviewsCount ?? 0)"
				case .failure(let error):
					//TODO: - обработать ошибку
					print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)
		reviewsListSubject.onNext(())
	}

	func updateProfile() {
		// title label
		view.titleNameLabel.textAlignment = .center
		view.titleNameLabel.textColor = Colors.mainTextColor
		view.titleNameLabel.font = Saira.bold.of(size: 22)
		view.titleNameLabel.text = lawyerProfile?.fullName
		// city label
		view.cityLabel.textAlignment = .center
		view.cityLabel.textColor = Colors.mainTextColor
		view.cityLabel.font = SFUIDisplay.light.of(size: 14)
		di.localStorageService.getRussianCities().forEach { city in
			if city.cityCode == lawyerProfile?.cityCode?.first {
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
		view.emailLabel.text = self.di.keyChainService.getValue(for: Constants.KeyChainKeys.email)

		// phone label
		view.phoneLabel.textAlignment = .center
		view.phoneLabel.textColor = Colors.mainTextColor
		view.phoneLabel.font = SFUIDisplay.medium.of(size: 18)
		view.phoneLabel.text = self.di.keyChainService.getValue(for: Constants.KeyChainKeys.phoneNumber)

		//MARK: - Update containerView with issues
		updateIssuesContainerView(with: lawyerProfile?.subIssueCodes ?? [])

		updateVisability()
	}

	private func updateVisability() {
		if let settings = di.localStorageService.getSettings(for: lawyerProfile?.id ?? 0) {
			view.emailLabel.isHidden = !settings.isEmailVisible
			view.phoneLabel.isHidden = !settings.isPhoneVisible
		}
	}

	private func updateVisability(with settings: SettingsModel) {
		view.emailLabel.isHidden = !settings.isEmailVisible
		view.phoneLabel.isHidden = !settings.isPhoneVisible
	}

	private func updateIssuesContainerView(with issues: [Int]) {
		let screenWidth = UIScreen.main.bounds.width
		let containerWidth = screenWidth - 70
		var currentLineWidth: CGFloat = 0
		var lastHorizontalStackView: UIStackView?

		view.issuesStackView.subviews.forEach {
			$0.removeFromSuperview()
		}

		di.commonDataNetworkService.issueTypes?
			.compactMap { $0.subIssueTypeList }
			.reduce([], +)
			.filter { issues.contains($0.subIssueCode ?? 0) }
			.forEach { issueType in
				let label = IssueLabel(labelColor: Colors.issueLabelColor,
									   subIssueCode: issueType.subIssueCode ?? 0)
				label.text = issueType.title
				let labelWidth = label.intrinsicContentSize.width + 20

				let viewWithLabel = UIView()
				viewWithLabel.layer.cornerRadius = 11
				viewWithLabel.backgroundColor = Colors.issueLabelColor
				viewWithLabel.addSubview(label)
				label.snp.makeConstraints {
					$0.top.equalToSuperview().offset(5)
					$0.bottom.equalToSuperview().offset(-5)
					$0.leading.equalToSuperview().offset(7)
					$0.trailing.equalToSuperview().offset(-7)
				}

				if let lastStackView = lastHorizontalStackView,
				   currentLineWidth + labelWidth + 10 < containerWidth {
					lastStackView.addArrangedSubview(viewWithLabel)
					currentLineWidth += labelWidth
				} else {
					let horizontalStackView = createHorizontalStackView()
					view.issuesStackView.addArrangedSubview(horizontalStackView)
					horizontalStackView.addArrangedSubview(viewWithLabel)
					lastHorizontalStackView = horizontalStackView
					currentLineWidth = labelWidth
				}
			}
	}

	private func createHorizontalStackView() -> UIStackView {
		let horizontalStackView = UIStackView()
		horizontalStackView.axis = .horizontal
		horizontalStackView.distribution = .fill
		horizontalStackView.alignment = .center
		horizontalStackView.spacing = 10

		return horizontalStackView
	}

	func removeBindings() {}
}
