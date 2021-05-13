//
//  ClientProfileViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 20.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ClientProfileViewModel: ViewModel, HasDependencies {
	var view: ClientProfileViewControllerProtocol!
	var router: ClientProfileRouterProtocol
	var clientImageSubject: PublishSubject<Any>?
	private let settingsClientSubject = PublishSubject<Any>()

	typealias Dependencies =
		HasLocalStorageService &
		HasLawyersNetworkService &
		HasKeyChainService &
		HasClientNetworkService
	lazy var di: Dependencies = DI.dependencies
	var clientProfile: UserProfile? {
		di.localStorageService.getCurrenClientProfile()
	}

	private var settingsClient: SettingsModel?

	private let animationDuration = 0.15
	private var disposeBag = DisposeBag()
	private var positiveReviewsCount = 0
	private var negativeReviewsCount = 0
	let reviewsListSubject = PublishSubject<Any>()
	private var reviews = [UserReview]()

	init(router: ClientProfileRouterProtocol) {
		self.router = router
	}

	func viewDidSet() {
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
		if let image = self.di.localStorageService.getImage(with: "\(self.clientProfile?.id ?? 0)_profile_image.jpeg") {
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
												  usertId: self?.clientProfile?.id ?? 0,
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
		view.ratingLabel.text = String(format: "%.1f", clientProfile?.averageRate ?? 0)
		view.ratingLabel.textColor = Colors.mainTextColor
		view.ratingLabel.font = SFUIDisplay.bold.of(size: 18)

		settingsClientSubject
			.asObservable()
			.do(onNext: { [unowned self] _ in
				guard let _ = self.di.localStorageService.getSettings(for: self.clientProfile?.id ?? 0) else {
					return
				}
				self.updateVisability()
			})
			.flatMap { [unowned self] _ in
				self.di.clientNetworkService.getSettings(profileId: self.clientProfile?.id ?? 0)
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
		settingsClientSubject.onNext(())

		clientImageSubject = PublishSubject<Any>()
		clientImageSubject?
			.asObservable()
			.flatMap { [unowned self] _ in
				self.di.clientNetworkService.getPhoto(profileId: clientProfile?.id ?? 0)
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

		reviewsListSubject
			.asObservable()
			.flatMap { [unowned self] _ in
				self.di.lawyersNetworkService.getReviews(for: clientProfile?.id ?? 0,
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
		if let settings = di.localStorageService.getSettings(for: clientProfile?.id ?? 0) {
			view.emailLabel.isHidden = !settings.isEmailVisible
			view.phoneLabel.isHidden = !settings.isPhoneVisible
		}
	}

	private func updateVisability(with settings: SettingsModel) {
		view.emailLabel.isHidden = !settings.isEmailVisible
		view.phoneLabel.isHidden = !settings.isPhoneVisible
	}

	func updateProfile() {
		// title label
		view.titleNameLabel.textAlignment = .center
		view.titleNameLabel.textColor = Colors.mainTextColor
		view.titleNameLabel.font = Saira.bold.of(size: 22)
		view.titleNameLabel.text = clientProfile?.fullName
		// city label
		view.cityLabel.textAlignment = .center
		view.cityLabel.textColor = Colors.mainTextColor
		view.cityLabel.font = SFUIDisplay.light.of(size: 14)
		di.localStorageService.getRussianCities().forEach { city in
			if city.cityCode == clientProfile?.cityCode?.first {
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

		updateVisability()
	}

	func removeBindings() {}
}
