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

	typealias Dependencies =
		HasLocalStorageService &
		HasKeyChainService &
		HasClientNetworkService
	lazy var di: Dependencies = DI.dependencies
	var clientProfile: UserProfile? {
		di.localStorageService.getCurrenClientProfile()
	}
	private var settings: SettingsModel? {
		di.localStorageService.getSettings(for: clientProfile?.id ?? 0)
	}

	private let animationDuration = 0.15
	private var disposeBag = DisposeBag()
	private var positiveReviewsCount = 0
	private var negativeReviewsCount = 0

	init(router: ClientProfileRouterProtocol) {
		self.router = router
	}

	func viewDidSet() {
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

		// reviews
		view.reviewsTitleLabel.textColor = Colors.mainTextColor
		view.reviewsTitleLabel.font = SFUIDisplay.light.of(size: 18)
		view.reviewsTitleLabel.text = "profile.reviews".localized
		di.localStorageService.getReviews().forEach {
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
		view.ratingLabel.text = String(format: "%.1f", di.localStorageService.getCurrenClientProfile()?.averageRate ?? 0)
		view.ratingLabel.textColor = Colors.mainTextColor
		view.ratingLabel.font = SFUIDisplay.bold.of(size: 18)
	}

	func updateProfile() {
		// avatar
		if let image = di.localStorageService.getImage(with: "\(clientProfile?.id ?? 0)_profile_image.jpeg") {
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
		view.emailLabel.isHidden = !(settings?.isEmailVisible ?? true)
		// phone label
		view.phoneLabel.textAlignment = .center
		view.phoneLabel.textColor = Colors.mainTextColor
		view.phoneLabel.font = SFUIDisplay.medium.of(size: 18)
		view.phoneLabel.text = self.di.keyChainService.getValue(for: Constants.KeyChainKeys.phoneNumber)
		view.phoneLabel.isHidden = !(settings?.isPhoneVisible ?? true)

		clientImageSubject = PublishSubject<Any>()
		clientImageSubject?
			.asObservable()
			.flatMap ({ _ -> Observable<Bool> in
				if let image = self.di.localStorageService
					.getImage(with: "\(self.clientProfile?.id ?? 0)_profile_image.jpeg") {
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
				self.di.clientNetworkService.getPhoto(profileId: clientProfile?.id ?? 0)
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

	func removeBindings() {}
}
