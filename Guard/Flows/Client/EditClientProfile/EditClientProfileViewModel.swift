//
//  EditClientProfileViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 10.10.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class EditClientProfileViewModel: ViewModel, HasDependencies {
	var view: EditClientProfileViewControllerProtocol!
	private let animationDuration = 0.15
	var userProfile: UserProfile
	private var disposeBag = DisposeBag()
	private var editClientSubject: PublishSubject<UserProfile>?

	var currentCities = [Int]()
	//TODO: - Change when countries number increase
	private var currentCountries: [Int] {
		[7]
	}
	var editImageData: Data?

	typealias Dependencies =
		HasAlertService &
		HasKeyChainService &
		HasClientNetworkService &
		HasLocalStorageService
	lazy var di: Dependencies = DI.dependencies

	init(userProfile: UserProfile) {
		self.userProfile = userProfile
	}

	func viewDidSet() {
		currentCities = di.localStorageService.getCurrenClientProfile()?.cityCode ?? []
		// back button
		view.backButton.setImage(#imageLiteral(resourceName: "icn_back_arrow"), for: .normal)
		view.backButton.rx
			.tap
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.backButton.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.backButton.alpha = 1
					})
				})
			})
			.subscribe(onNext: { [unowned self] _ in
				self.view.navController?.popViewController(animated: true)
			}).disposed(by: disposeBag)
		// confirm button
		view.confirmButton.setImage(#imageLiteral(resourceName: "confirm_icn"), for: .normal)
		view.confirmButton.rx
			.tap
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.confirmButton.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.confirmButton.alpha = 1
					})
				})
			})
			.subscribe(onNext: { [unowned self] _ in
				self.di.alertService.showAlert(title: "edit_profile.alert.title".localized,
											   message: "edit_profile.alert.message".localized,
											   okButtonTitle: "alert.yes".localized.uppercased(),
											   cancelButtonTitle: "alert.no".localized.uppercased()) { result in
					if result {
						self.view.loadingView.startAnimating()

						userProfile.firstName = view.nameTextField.text
						userProfile.lastName = view.surnameTextField.text

						userProfile.countryCode = currentCountries
						userProfile.cityCode = currentCities
						self.editClientSubject?.onNext(userProfile)
					}
				}
			}).disposed(by: disposeBag)

		// avatar
		if let image = self.di.localStorageService
			.getImage(with: "\(userProfile.id)_profile_image.jpeg") {
			view.avatarImageView.image = image
		} else {
			view.avatarImageView.image = #imageLiteral(resourceName: "profile_icn").withRenderingMode(.alwaysTemplate)
			view.avatarImageView.tintColor = Colors.lightGreyColor
		}
		view.avatarImageView.clipsToBounds = true

		// edit view
		view.editPhotoView.backgroundColor = Colors.blackColor.withAlphaComponent(0.5)
		view.editPhotoView.layer.cornerRadius = 38
		view.editPhotoView.rx
			.tapGesture()
			.when(.recognized)
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.editPhotoView.alpha = 0.7
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.editPhotoView.alpha = 1
					})
				})
			})
			.subscribe(onNext: { [unowned self] _ in
				self.view.takePhotoFromGallery()
			}).disposed(by: disposeBag)
		// name
		view.nameTextField.configure(placeholderText: "edit_profile.name.placeholder".localized)
		if let firstName = userProfile.firstName,
			!firstName.isEmpty {
			view.nameTextField.text = firstName
		}
		// surname
		view.surnameTextField.configure(placeholderText: "edit_profile.surname.placeholder".localized)
		if let lastName = userProfile.lastName,
			!lastName.isEmpty {
			view.surnameTextField.text = lastName
		}
		// phone
		view.phoneTextField.configure(placeholderText: "edit_profile.phone.placeholder".localized)
		if let phone = di.keyChainService.getValue(for: Constants.KeyChainKeys.phoneNumber),
			!phone.isEmpty {
			view.phoneTextField.text = phone
		}
		// email
		view.emailTextField.keyboardType = .emailAddress
		view.emailTextField.autocapitalizationType = .none
		view.emailTextField.configure(placeholderText: "edit_profile.email.placeholder".localized)
		if let email = di.keyChainService.getValue(for: Constants.KeyChainKeys.email) {
			view.emailTextField.text = email
		}

		//MARK: - Country select
		currentCountries.forEach { country in
			if country == di.localStorageService.getCurrenClientProfile()?.countryCode?.first {
				if let locale = Locale.current.languageCode, locale == "ru" {
					view.countrySelectView.titleLabel.text = "Россия"
				} else {
					view.countrySelectView.titleLabel.text = "Russia"
				}
			}
		}
		view.countrySelectView.rx
			.tapGesture()
			.when(.recognized)
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.countrySelectView.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.countrySelectView.alpha = 1
					})
				})
			})
			.subscribe(onNext: { [unowned self] _ in
				self.view.showActionSheet(with: [view.countrySelectView.titleLabel.text ?? ""]) { [weak self] title in
					self?.view.countrySelectView.titleLabel.text = title
				}
			}).disposed(by: disposeBag)

		//MARK: - City select
		di.localStorageService.getRussianCities().forEach { city in
			if city.cityCode == currentCities.first {
				if let locale = Locale.current.languageCode,
				   locale == "ru" {
					view.citySelectView.titleLabel.text = city.title
				} else {
					view.citySelectView.titleLabel.text = city.titleEn
				}
			}
		}
		view.citySelectView.rx
			.tapGesture()
			.when(.recognized)
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.citySelectView.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.citySelectView.alpha = 1
					})
				})
			})
			.subscribe(onNext: { [unowned self] _ in
				self.view.showActionSheet(with: [view.citySelectView.titleLabel.text ?? ""]) { [weak self] title in
					self?.view.citySelectView.titleLabel.text = title
					// add cityCode
					di.localStorageService.getRussianCities().forEach {
						if $0.title == title || $0.titleEn == title {
							if !currentCities.contains($0.cityCode) {
								currentCities.append($0.cityCode)
							}
						}
					}
				}
			}).disposed(by: disposeBag)

		// swipe to go back
		view.view
			.rx
			.swipeGesture(.right)
			.when(.recognized)
			.subscribe(onNext: { [unowned self] _ in
				self.view.navController?.popViewController(animated: true)
			}).disposed(by: disposeBag)

		editClientSubject = PublishSubject<UserProfile>()
		editClientSubject?
			.asObservable()
			.flatMap { [unowned self] profile in
				self.di.clientNetworkService.editClient(profile: profile,
														email: view.emailTextField.text ?? "",
														phone: view.phoneTextField.text ?? "")
			}
			.filter { result in
				switch result {
				case .success:
					return true
				default:
					return false
				}
			}
			.flatMap { [unowned self] _ in
				self.di.clientNetworkService.editPhoto(imageData: self.editImageData,
													   profileId: self.userProfile.id)
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				self?.view.loadingView.stopAnimating()
				switch result {
					case .success:
						if let profile = self?.userProfile {
							self?.di.localStorageService.saveProfile(profile)
						}
						self?.di.keyChainService.save(self?.view.emailTextField.text ?? "",
													  for: Constants.KeyChainKeys.email)
						self?.di.keyChainService.save(self?.view.phoneTextField.text ?? "",
													  for: Constants.KeyChainKeys.phoneNumber)
						self?.view.navController?.popViewController(animated: true)
					case .failure(let error):
						//TODO: - обработать ошибку
						print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)
	}
	
	func removeBindings() {}
}
