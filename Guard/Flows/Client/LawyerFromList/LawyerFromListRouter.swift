//
//  LawyerFromListRouter.swift
//  Guard
//
//  Created by Alexandr Bukharin on 27.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import RxSwift

protocol LawyerFromListRouterProtocol {
	func passageToReviewsList(isMyReviews: Bool,
							  reviewsListSubject: PublishSubject<Any>,
							  usertId: Int,
							  reviews: [UserReview])
}

final class LawyerFromListRouter: BaseRouter, LawyerFromListRouterProtocol {
	func passageToReviewsList(isMyReviews: Bool,
							  reviewsListSubject: PublishSubject<Any>,
							  usertId: Int,
							  reviews: [UserReview]) {
		let reviewsRouter = ReviewsListRouter()
		reviewsRouter.navigationController = self.navigationController
		let reviewsListViewModel = ReviewsListViewModel(router: reviewsRouter,
														isMyReviews: isMyReviews,
														reviewsUpdateSubject: reviewsListSubject,
														reviewsListSubject: usertId,
														reviews: reviews)
		let viewController = ReviewsListViewController(viewModel: reviewsListViewModel)
		viewController.hidesBottomBarWhenPushed = true
		self.navigationController?.pushViewController(viewController, animated: true)
	}
}
