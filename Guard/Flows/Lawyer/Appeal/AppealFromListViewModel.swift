//
//  AppealFromListViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 24.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class AppealFromListViewModel: ViewModel, HasDependencies {
	var view: AppealFromListViewControllerProtocol!
	private let animationDuration = 0.15
	private var disposeBag = DisposeBag()
	private let appeal: ClientAppeal
	let clientProfileSubject = PublishSubject<Any>()
	typealias Dependencies =
		HasLocalStorageService &
		HasAppealsNetworkService &
		HasCommonDataNetworkService &
		HasClientNetworkService
	lazy var di: Dependencies = DI.dependencies
	private var issueTitle: String?
	private var clientProfile: UserProfile?

	init(appeal: ClientAppeal) {
		self.appeal = appeal
	}

	func viewDidSet() {
		// set issue title
		di.commonDataNetworkService.subIssueTypes?.forEach {
			if appeal.subIssueCode == $0.subIssueCode {
				issueTitle = $0.title
			}
		}

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

		// title
		view.titleTextField.configure(placeholderText: "new_appeal.title.textfield.placeholder".localized,
									  isSeparatorHidden: true)
		view.titleTextField.text = appeal.title
		view.titleTextField.isUserInteractionEnabled = false

		// text view
		view.descriptionTextView.isEditable = false
		view.descriptionTextView.textColor = Colors.mainTextColor
		view.descriptionTextView.text = "new_appeal.textview.placeholder".localized
		view.descriptionTextView.font = SFUIDisplay.regular.of(size: 16)
		view.descriptionTextView.textAlignment = .natural
		view.descriptionTextView.backgroundColor = Colors.whiteColor
		view.descriptionTextView.text = appeal.appealDescription

		view.issueTypeLabel.font = SFUIDisplay.medium.of(size: 15)
		view.issueTypeLabel.textColor = Colors.whiteColor
		view.issueTypeLabel.backgroundColor = Colors.warningColor
		view.issueTypeLabel.layer.cornerRadius = 12
		view.issueTypeLabel.clipsToBounds = true

		view.issueTypeLabel.isHidden = issueTitle == nil
		view.issueTypeLabel.text = issueTitle
		view.issueTypeLabel.textAlignment = .center

		view.profileView.backgroundColor = Colors.lightBlueColor
		view.profileView.layer.cornerRadius = 18
		view.profileView.isHidden = true
		view.profileView
			.rx
			.tapGesture()
			.when(.recognized)
			.subscribe(onNext: { _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.profileView.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.profileView.alpha = 1
					})
				})
				guard let profile = self.clientProfile else { return }
				let controller = ClientFromAppealModuleFactory.createModule(clientProfile: profile,
																			navController: self.view.navController)
				self.view.navController?.pushViewController(controller, animated: true)
			}).disposed(by: disposeBag)

		view.profileNameLabel.font = SFUIDisplay.regular.of(size: 15)
		view.profileNameLabel.textColor = Colors.mainTextColor

		view.profileImageView.layer.cornerRadius = 11
		view.profileImageView.clipsToBounds = true

		clientProfileSubject
			.asObservable()
			.do(onNext: { [unowned self] _ in
				self.view.loadingView.startAnimating()
			})
			.flatMap { [unowned self] _ in
				self.di.appealsNetworkService.getClient(by: appeal.id)
			}
			.flatMap ({ [weak self] result -> Observable<UserProfile?> in
				switch result {
					case .success(let profile):
						self?.clientProfile = profile
						self?.view.profileNameLabel.text = profile.fullName
						self?.view.profileView.isHidden = false
						return .just(profile)
					case .failure:
						self?.view.loadingView.stopAnimating()
						return .just(nil)
				}
			})
			.flatMap { [unowned self] profile in
				self.di.clientNetworkService.getPhoto(profileId: profile?.id ?? 0)
			}
			.flatMap ({ [weak self] result -> Observable<Bool> in
				switch result {
				case .success(let data):
					if let image = UIImage(data: data) {
						self?.view.profileImageView.image = image
					} else {
						self?.view.profileImageView.image = #imageLiteral(resourceName: "tab_profile_icn").withRenderingMode(.alwaysTemplate)
						self?.view.profileImageView.tintColor = Colors.lightGreyColor
					}
					return .just(true)
				case .failure(let error):
					print(error.localizedDescription)
					self?.view.loadingView.stopAnimating()
					return .just(false)
				}
			})
			.flatMap { [unowned self] _ in
				self.di.clientNetworkService
					.getSettings(profileId: self.clientProfile?.id ?? 0)
			}
			.subscribe(onNext: { [weak self] result in
				self?.view.loadingView.stopAnimating()
				switch result {
				case .success(let settings):
					if settings.isChatEnabled == true {
						self?.view.chatButton.isHidden = false
					}
					self?.clientProfile?.settings = settings
				case .failure(let error):
					//TODO: - обработать ошибку
					print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)

		// MARK: - ChatButton
		view.chatButton.isHidden = true
		view.chatButton
			.rx
			.tap
			.subscribe(onNext: { [weak self] _ in
				self?.view.tabBarViewController?.selectedIndex = 1

				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					guard
						let navigationController = self?.view.tabBarViewController?.viewControllers?[1] as? UINavigationController,
						let vc = navigationController.viewControllers.first as? ConversationsListViewController,
						let profile = self?.clientProfile else { return }

					let newConversation = ChatConversation(id: -1,
														   dateCreated: "",
														   userId: profile.id,
														   lastMessage: "",
														   appealId: self?.appeal.id ?? 0,
														   userFirstName: profile.firstName,
														   userLastName: profile.lastName,
														   userPhoto: profile.photo)

					vc.viewModel.toChatWithLawyer?.onNext(newConversation)
				}
			}).disposed(by: disposeBag)

		clientProfileSubject.onNext(())
	}

	func removeBindings() {}
}
