//
//  ClientProfileRouter.swift
//  Guard
//
//  Created by Alexandr Bukharin on 20.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxSwift
import Foundation

protocol ClientProfileRouterProtocol {
	var toSettingsSubject: PublishSubject<Any> { get }
	var toEditSubject: PublishSubject<UserProfile> { get }
	func passageToReviewsList(isMyReviews: Bool,
							  usertId: Int,
							  reviews: [UserReview])
}

final class ClientProfileRouter: BaseRouter, ClientProfileRouterProtocol {
	var toSettingsSubject = PublishSubject<Any>()
	var toEditSubject = PublishSubject<UserProfile>()
	let toAuthSubject: PublishSubject<Any>
	private var disposeBag = DisposeBag()

	init(toAuthSubject: PublishSubject<Any>) {
		self.toAuthSubject = toAuthSubject
		super.init()
		createTransitions()
	}

	private func createTransitions() {
		// to settings
		toSettingsSubject
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [unowned self] _ in
				self.passageToSettings()
			})
			.disposed(by: disposeBag)
		// to edit
		toEditSubject
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [unowned self] userProfile in
				self.passageToEdit(userProfile: userProfile)
			})
			.disposed(by: disposeBag)
	}

	private func passageToSettings() {
		let settingsController = SettingsViewController(viewModel: SettingsViewModel(userRole: .client,
																					 logoutSubject: toAuthSubject))
		settingsController.hidesBottomBarWhenPushed = true
		self.navigationController?.pushViewController(settingsController, animated: true)
	}

	private func passageToEdit(userProfile: UserProfile) {
		let editController = EditClientProfileViewController(viewModel: EditClientProfileViewModel(userProfile: userProfile))
		editController.hidesBottomBarWhenPushed = true
		self.navigationController?.pushViewController(editController, animated: true)
	}

	func passageToReviewsList(isMyReviews: Bool,
							  usertId: Int,
							  reviews: [UserReview]) {
		let reviewsRouter = ReviewsListRouter()
		reviewsRouter.navigationController = self.navigationController
		let reviewsListViewModel = ReviewsListViewModel(router: reviewsRouter,
														isMyReviews: isMyReviews,
														userId: usertId,
														reviews: reviews)
		let viewController = ReviewsListViewController(viewModel: reviewsListViewModel)
		viewController.hidesBottomBarWhenPushed = true
		self.navigationController?.pushViewController(viewController, animated: true)
	}
}
