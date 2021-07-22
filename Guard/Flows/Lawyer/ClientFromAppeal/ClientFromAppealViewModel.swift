//
//  ClientFromAppealViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 27.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ClientFromAppealViewModel: ViewModel, HasDependencies {
	var view: ClientFromAppealViewControllerProtocol!
	var router: ClientFromAppealRouterProtocol
	var clientImageSubject: PublishSubject<Any>?
	private var settingsClientSubject = PublishSubject<Any>()

	typealias Dependencies =
		HasLocalStorageService &
		HasKeyChainService &
		HasLawyersNetworkService &
		HasClientNetworkService
	lazy var di: Dependencies = DI.dependencies
	private let clientProfile: UserProfile

	private var settingsClient: SettingsModel?

	private let animationDuration = 0.15
	private var disposeBag = DisposeBag()
	private var positiveReviewsCount = 0
	private var negativeReviewsCount = 0
	let reviewsListSubject = PublishSubject<Any>()
	private var reviews = [UserReview]()

	init(clientProfile: UserProfile,
		 router: ClientFromAppealRouterProtocol) {
		self.clientProfile = clientProfile
		self.settingsClient = clientProfile.settings
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
				guard let reviewsListSubject = self?.reviewsListSubject else { return }
				self?.router.passageToReviewsList(isMyReviews: false,
												  reviewsUpdateSubject: reviewsListSubject,
												  usertId: self?.clientProfile.id ?? 0,
												  reviews: self?.reviews ?? [])
			}).disposed(by: disposeBag)

		clientProfile.reviewList?.forEach() {
			if $0.rating > 2 {
				positiveReviewsCount += 1
			} else {
				negativeReviewsCount += 1
			}
		}

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
		view.ratingLabel.text = String(format: "%.1f", clientProfile.averageRate ?? 0)
		view.ratingLabel.textColor = Colors.mainTextColor
		view.ratingLabel.font = SFUIDisplay.bold.of(size: 18)

		clientImageSubject = PublishSubject<Any>()
		clientImageSubject?
			.asObservable()
			.flatMap { [unowned self] _ in
				self.di.clientNetworkService.getPhoto(profileId: clientProfile.id)
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

		settingsClientSubject
			.asObservable()
			.flatMap { [unowned self] _ in
				self.di.clientNetworkService.getSettings(profileId: clientProfile.id)
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				switch result {
				case .success(let settings):
					self?.settingsClient = settings
					self?.updateVisability()
				case .failure(let error):
					//TODO: - обработать ошибку
					print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)
		settingsClientSubject.onNext(())

		reviewsListSubject
			.asObservable()
			.flatMap { [unowned self] _ in
				self.di.lawyersNetworkService.getReviews(for: clientProfile.id,
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

	private func updateVisability() {
		guard let settings = settingsClient else { return }
		view.emailLabel.isHidden = !settings.isEmailVisible
		view.phoneLabel.isHidden = !settings.isPhoneVisible
	}

	func updateProfile() {
		// title label
		view.titleNameLabel.textAlignment = .center
		view.titleNameLabel.textColor = Colors.mainTextColor
		view.titleNameLabel.font = Saira.bold.of(size: 22)
		view.titleNameLabel.text = clientProfile.fullName
		// city label
		view.cityLabel.textAlignment = .center
		view.cityLabel.textColor = Colors.mainTextColor
		view.cityLabel.font = SFUIDisplay.light.of(size: 14)
		di.localStorageService.getRussianCities().forEach { city in
			if city.cityCode == clientProfile.cityCode?.first {
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
		if clientProfile.isAnonymus == false {
			view.emailLabel.text = clientProfile.email
		}
		// phone label
		view.phoneLabel.textAlignment = .center
		view.phoneLabel.textColor = Colors.mainTextColor
		view.phoneLabel.font = SFUIDisplay.medium.of(size: 18)
		view.phoneLabel.text = clientProfile.phoneNumber

		updateVisability()
	}

	func removeBindings() {}
}
