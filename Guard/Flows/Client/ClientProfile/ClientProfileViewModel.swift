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
	private var settingsListSubject: PublishSubject<Any>?

	typealias Dependencies =
		HasLocalStorageService &
		HasKeyChainService &
		HasClientNetworkService
	lazy var di: Dependencies = DI.dependencies
	var localClientProfile: UserProfile? {
		di.localStorageService.getCurrenClientProfile()
	}
	private var clientProfileFromAppeal: UserProfile?
	var currentProfile: UserProfile? {
		if let profile = clientProfileFromAppeal {
			return profile
		} else {
			return localClientProfile
		}
	}
	private var currentReviews: [UserReview]? {
		if let profile = clientProfileFromAppeal {
			return profile.reviewList
		} else {
			return di.localStorageService.getReviews()
		}
	}
	private var settings: SettingsModel? {
		get {
			if let profile = clientProfileFromAppeal {
				return profile.settings
			} else {
				return di.localStorageService.getSettings(for: localClientProfile?.id ?? 0)
			}
		}
		set {
			self.settings = newValue
		}
	}

	private let animationDuration = 0.15
	private var disposeBag = DisposeBag()
	private var positiveReviewsCount = 0
	private var negativeReviewsCount = 0

	init(clientProfileFromAppeal: UserProfile?,
		 router: ClientProfileRouterProtocol) {
		self.clientProfileFromAppeal = clientProfileFromAppeal
		self.router = router
	}

	func viewDidSet() {
		// swipe to go back
		view.view
			.rx
			.swipeGesture(.right)
			.when(.recognized)
			.subscribe(onNext: { [unowned self] _ in
				guard clientProfileFromAppeal != nil else { return }
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
		view.backButtonView.isHidden = clientProfileFromAppeal == nil

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
		view.threedotsButton.isHidden = clientProfileFromAppeal != nil

		view.phoneLabel
			.rx
			.tapGesture()
			.when(.recognized)
			.filter { _ in
				if let _ = self.clientProfileFromAppeal {
					return true
				} else {
					return false
				}
			}
			.subscribe(onNext: { [weak self] _ in
				guard
					let phone = self?.view.phoneLabel.text,
					let url = URL(string: "tel://\(phone)"),
					UIApplication.shared.canOpenURL(url) else { return }
				UIApplication.shared.open(url)
			}).disposed(by: disposeBag)

		view.emailLabel
			.rx
			.tapGesture()
			.when(.recognized)
			.filter { _ in
				if let _ = self.clientProfileFromAppeal {
					return true
				} else {
					return false
				}
			}
			.subscribe(onNext: { [weak self] _ in
				guard
					let email = self?.view.emailLabel.text,
					let url = URL(string: "mailto:\(email)"),
					UIApplication.shared.canOpenURL(url) else { return }
				UIApplication.shared.open(url)
			}).disposed(by: disposeBag)

		// reviews
		view.reviewsTitleLabel.textColor = Colors.mainTextColor
		view.reviewsTitleLabel.font = SFUIDisplay.light.of(size: 18)
		view.reviewsTitleLabel.text = "profile.reviews".localized

		view.reviewsView
			.rx
			.tapGesture()
			.when(.recognized)
			.subscribe(onNext: { [weak self] _ in
				self?.router.passageToReviewsList(isMyReviews: self?.clientProfileFromAppeal == nil,
												  usertId: self?.currentProfile?.id ?? 0,
												  reviews: self?.currentReviews ?? [])
			}).disposed(by: disposeBag)

		if let profile = clientProfileFromAppeal {
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
		view.ratingLabel.text = String(format: "%.1f", currentProfile?.averageRate ?? 0)
		view.ratingLabel.textColor = Colors.mainTextColor
		view.ratingLabel.font = SFUIDisplay.bold.of(size: 18)

		clientImageSubject = PublishSubject<Any>()
		clientImageSubject?
			.asObservable()
			.flatMap ({ _ -> Observable<Bool> in
				guard self.clientProfileFromAppeal == nil else {
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

		settingsListSubject = PublishSubject<Any>()
		settingsListSubject?
			.filter { _ in
				if self.settings == nil {
					return true
				} else {
					return false
				}
			}
			.asObservable()
			.flatMap { [unowned self] _ in
				self.di.clientNetworkService.getSettings(profileId: self.currentProfile?.id ?? 0)
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				switch result {
					case .success(let settings):
						self?.settings = settings
						self?.updateVisability()
					case .failure(let error):
						//TODO: - обработать ошибку
						print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)
		settingsListSubject?.onNext(())
	}

	private func updateVisability() {
		view.emailLabel.isHidden = !(settings?.isEmailVisible ?? false)
		view.phoneLabel.isHidden = !(settings?.isPhoneVisible ?? false)
	}

	func updateProfile() {
		// avatar
		if let image = di.localStorageService.getImage(with: "\(currentProfile?.id ?? 0)_profile_image.jpeg") {
			view.avatarImageView.image = image
		} else {
			view.avatarImageView.image = #imageLiteral(resourceName: "tab_profile_icn").withRenderingMode(.alwaysTemplate)
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
		if let profile = clientProfileFromAppeal {
			view.emailLabel.text = profile.email
		} else {
			view.emailLabel.text = self.di.keyChainService.getValue(for: Constants.KeyChainKeys.email)
		}
		// phone label
		view.phoneLabel.textAlignment = .center
		view.phoneLabel.textColor = Colors.mainTextColor
		view.phoneLabel.font = SFUIDisplay.medium.of(size: 18)
		if let profile = clientProfileFromAppeal {
			view.phoneLabel.text = profile.phoneNumber
		} else {
			view.phoneLabel.text = self.di.keyChainService.getValue(for: Constants.KeyChainKeys.phoneNumber)
		}

		updateVisability()
	}

	func removeBindings() {}
}
