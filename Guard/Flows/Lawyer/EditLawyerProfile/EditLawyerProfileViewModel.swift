//
//  EditLawyerProfileViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 21.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class EditLawyerProfileViewModel: ViewModel {
	var view: EditLawyerProfileViewControllerProtocol!
	private let animationDuration = 0.15
	var userProfile: UserProfile
	private var disposeBag = DisposeBag()
	private var editLawyerSubject: PublishSubject<UserProfile>?
	private let selectIssuesSubject = PublishSubject<[Int]>()

	var currentCities = [Int]()
	//TODO: - Change when countries number increase
	private var currentCountries: [Int] {
		[7]
	}
	var editImageData: Data?
	private var currentIssueCodes = [Int]()
	private var addIssueButton: AddIssueButton?
	private var router: EditProfileRouterProtocol

	typealias Dependencies =
		HasAlertService &
		HasKeyChainService &
		HasClientNetworkService &
		HasLocalStorageService &
		HasCommonDataNetworkService &
		HasLawyersNetworkService
	lazy var di: Dependencies = DI.dependencies

	init(userProfile: UserProfile,
		 router: EditProfileRouterProtocol) {
		self.userProfile = userProfile
		self.router = router
	}

	func viewDidSet() {
		currentCities = di.localStorageService.getCurrenClientProfile()?.cityCode ?? []
		currentIssueCodes = userProfile.subIssueCodes ?? []

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
						self.view.loadingView.play()

						userProfile.firstName = view.nameTextField.text
						userProfile.lastName = view.surnameTextField.text

						userProfile.countryCode = currentCountries
						userProfile.cityCode = currentCities

						// set issue codes
						userProfile.subIssueCodes = Array(Set(currentIssueCodes))

						self.editLawyerSubject?.onNext(userProfile)
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
		view.phoneTextField
			.rx
			.text
			.subscribe(onNext: { [unowned self] text in
				self.view.phoneTextField.text = text?.phoneNumberFormat
			}).disposed(by: disposeBag)

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

		editLawyerSubject = PublishSubject<UserProfile>()
		editLawyerSubject?
			.asObservable()
			.filter { _ in
				// check if all edit views removed
				//let issueViewsArray = self.view.issuesStackView.subviews.compactMap { $0 as? EditIssueView }
				if self.currentIssueCodes.isEmpty {
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
						self.di.alertService.showAlert(title: "edit_profile.alert.title".localized,
													   message: "edit_lawyer.empty_issues.title".localized,
													   okButtonTitle: "alert.yes".localized.uppercased()) { _ in }
						self.view.loadingView.stop()
					}
					return false
				} else {
					return true
				}
			}
			.flatMap { [unowned self] profile in
				self.di.lawyersNetworkService.editLawyer(profile: profile,
														 email: view.emailTextField.text ?? "",
														 phone: view.phoneTextField.text ?? "")
			}
			.filter { result in
				switch result {
				case .success:
					self.saveProfile()
					// check is photo edited
					if self.editImageData == nil {
						self.view.loadingView.stop()
						self.view.navController?.popViewController(animated: true)
						return false
					} else {
						return true
					}
				default:
					self.view.loadingView.stop()
					return false
				}
			}
			.flatMap { [unowned self] _ in
				self.di.clientNetworkService.editPhoto(imageData: self.editImageData,
													   profileId: self.userProfile.id)
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				self?.view.loadingView.stop()
				switch result {
				case .success:
					self?.view.navController?.popViewController(animated: true)
				case .failure(let error):
					//TODO: - обработать ошибку
					print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)

		selectIssuesSubject
			.asObservable()
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] subIssueCodes in
				self?.currentIssueCodes = subIssueCodes
				self?.updateIssuesContainerView()
			}).disposed(by: disposeBag)

		view.issuesStackView.axis = .vertical
		view.issuesStackView.distribution = .fill
		view.issuesStackView.alignment = .center
		view.issuesStackView.spacing = 10
	}

	// MARK: - Save profile
	private func saveProfile() {
		di.localStorageService.saveProfile(userProfile)
		di.keyChainService.save(view.emailTextField.text ?? "",
								for: Constants.KeyChainKeys.email)
		di.keyChainService.save(view.phoneTextField.text ?? "",
								for: Constants.KeyChainKeys.phoneNumber)
	}

	private func updateIssuesContainerView(with issues: [Int]) {
		let screenWidth = UIScreen.main.bounds.width
		let containerWidth = screenWidth - 70
		var currentLineWidth: CGFloat = 0
		var lastHorizontalStackView: UIStackView?
		var isAddButtonAdded = false

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
				let labelWidth = label.intrinsicContentSize.width + 40

				let editIssueView = EditIssueView(editViewColor: Colors.issueLabelColor,
												  subIssueCode: issueType.subIssueCode ?? 0)
				editIssueView.editSubject
					.asObservable()
					.observeOn(MainScheduler.instance)
					.subscribe(onNext: { [weak self] code in
						self?.removeIssue(with: code)
					}).disposed(by: disposeBag)

				editIssueView.layer.cornerRadius = 11
				editIssueView.backgroundColor = Colors.issueLabelColor
				editIssueView.addSubview(label)
				label.snp.makeConstraints {
					$0.top.equalToSuperview().offset(5)
					$0.bottom.equalToSuperview().offset(-5)
					$0.leading.equalToSuperview().offset(7)
					$0.trailing.equalToSuperview().offset(-26)
				}

				if let lastStackView = lastHorizontalStackView,
				   currentLineWidth + labelWidth + 10 < containerWidth {
					lastStackView.addArrangedSubview(editIssueView)
					currentLineWidth += labelWidth
				} else {
					// add addButton
					if let lastStackView = lastHorizontalStackView,
					   isAddButtonAdded == false {
						createAddButton()
						guard let addIssueButton = addIssueButton else { return }
						lastStackView.addArrangedSubview(addIssueButton)
						isAddButtonAdded = true
					}

					let horizontalStackView = createHorizontalStackView()
					view.issuesStackView.addArrangedSubview(horizontalStackView)
					horizontalStackView.addArrangedSubview(editIssueView)
					lastHorizontalStackView = horizontalStackView
					currentLineWidth = labelWidth
				}
			}

		// if only one line with issues
		if let lastStackView = lastHorizontalStackView,
		   isAddButtonAdded == false {
			createAddButton()
			guard let addIssueButton = addIssueButton else { return }
			lastStackView.addArrangedSubview(addIssueButton)
			isAddButtonAdded = true
		}

		// if issues empty
		if issues.isEmpty,
		   isAddButtonAdded == false {
			createAddButton()
			guard let addIssueButton = addIssueButton else { return }
			view.issuesStackView.addArrangedSubview(addIssueButton)
			isAddButtonAdded = true
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

	func updateIssuesContainerView() {
		updateIssuesContainerView(with: currentIssueCodes)
	}

	private func createAddButton() {
		addIssueButton = AddIssueButton()
		addIssueButton?.snp.makeConstraints {
			$0.width.equalTo(26)
			$0.height.equalTo(23)
		}
		subscribeAddButton()
	}

	private func subscribeAddButton() {
		// add button
		addIssueButton?.rx
			.tap
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.addIssueButton?.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.addIssueButton?.alpha = 1
					})
				})
			})
			.subscribe(onNext: { [unowned self] _ in
				self.router.presentFilterScreenViewController(subIssuesCodes: currentIssueCodes,
															  filterIssuesSubject: selectIssuesSubject)
			}).disposed(by: disposeBag)

	}

	private func removeIssue(with code: Int) {
		self.di.alertService.showAlert(title: "edit_profile.alert.title".localized,
									   message: "edit_lawyer.remove_issue.title".localized,
									   okButtonTitle: "alert.yes".localized.uppercased(),
									   cancelButtonTitle: "alert.no".localized.uppercased()) { result in
			if result {
				self.currentIssueCodes = self.currentIssueCodes.filter { $0 != code }
				self.updateIssuesContainerView()
			}
		}
	}

	func removeBindings() {}
}
