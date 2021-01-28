//
//  LawyerProfileRouter.swift
//  Guard
//
//  Created by Alexandr Bukharin on 19.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import RxSwift

protocol LawyerProfileRouterProtocol {
	var toSettingsSubject: PublishSubject<Any> { get }
	var toEditSubject: PublishSubject<UserProfile> { get }
	func passageToReviewsList(isMyReviews: Bool,
							  usertId: Int,
							  reviews: [UserReview])
}

final class LawyerProfileRouter: BaseRouter, LawyerProfileRouterProtocol {
	var toAuthSubject: PublishSubject<Any>?
	var toSettingsSubject = PublishSubject<Any>()
	var toEditSubject = PublishSubject<UserProfile>()
	private var disposeBag = DisposeBag()

	init(toAuthSubject: PublishSubject<Any>?) {
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
		guard let authSubject = toAuthSubject else { return }
		let settingsController = SettingsViewController(viewModel: SettingsViewModel(userRole: .lawyer,
																					 logoutSubject: authSubject))
		settingsController.hidesBottomBarWhenPushed = true
		self.navigationController?.pushViewController(settingsController, animated: true)
	}

	private func passageToEdit(userProfile: UserProfile) {
		let router = EditProfileRouter()
		let viewModel = EditLawyerProfileViewModel(userProfile: userProfile,
												   router: router)
		let editController = EditLawyerProfileViewController(viewModel: viewModel)
		router.view = editController
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
