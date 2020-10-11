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
	let userProfile: UserProfile
	private var disposeBag = DisposeBag()

	typealias Dependencies = HasAlertService
	lazy var di: Dependencies = DI.dependencies

	init(userProfile: UserProfile) {
		self.userProfile = userProfile
	}

	func viewDidSet() {
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
				self.di.alertService.showAlert(with: "edit_profile.alert.title".localized,
											   message: "edit_profile.alert.message".localized) { result in
					if result {
						self.view.navController?.popViewController(animated: true)
					}
				}
			}).disposed(by: disposeBag)
		// avatar
		view.avatarImageView.image = #imageLiteral(resourceName: "profile_icn")
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
				//
			}).disposed(by: disposeBag)
		// name
		view.nameTextField.configure(placeholderText: "edit_profile.name.placeholder".localized)
		if !userProfile.firstName.isEmpty {
			view.nameTextField.text = userProfile.firstName
		}
		// surname
		view.surnameTextField.configure(placeholderText: "edit_profile.surname.placeholder".localized)
		if !userProfile.lastName.isEmpty {
			view.surnameTextField.text = userProfile.lastName
		}
		// phone
		view.phoneTextField.configure(placeholderText: "edit_profile.phone.placeholder".localized)
		if !userProfile.phone.isEmpty {
			view.phoneTextField.text = userProfile.phone
		}
		// email
		view.emailTextField.keyboardType = .emailAddress
		view.emailTextField.autocapitalizationType = .none
		view.emailTextField.configure(placeholderText: "edit_profile.email.placeholder".localized)
		if !userProfile.email.isEmpty {
			view.emailTextField.text = userProfile.email
		}
		// country select
		view.countrySelectView.titleLabel.text = "Russia" //userProfile.country
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
				self.view.showActionSheet(with: ["Russia"]) { [weak self] title in
					self?.view.countrySelectView.titleLabel.text = title
				}
			}).disposed(by: disposeBag)
		// city select
		view.citySelectView.titleLabel.text = "Moscow" //userProfile.city
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
				self.view.showActionSheet(with: ["Moscow"]) { [weak self] title in
					self?.view.citySelectView.titleLabel.text = title
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
	}
	
	func removeBindings() {}
}
