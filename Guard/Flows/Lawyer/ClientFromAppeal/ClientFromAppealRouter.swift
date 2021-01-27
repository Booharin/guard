//
//  ClientFromAppealRouter.swift
//  Guard
//
//  Created by Alexandr Bukharin on 27.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

protocol ClientFromAppealRouterProtocol {
	func passageToReviewsList(isMyReviews: Bool,
							  usertId: Int,
							  reviews: [UserReview])
}

final class ClientFromAppealRouter: BaseRouter, ClientFromAppealRouterProtocol {
	func passageToReviewsList(isMyReviews: Bool,
							  usertId: Int,
							  reviews: [UserReview]) {
		let reviewsRouter = ReviewsListRouter()
		let reviewsListViewModel = ReviewsListViewModel(router: reviewsRouter,
														isMyReviews: isMyReviews,
														userId: usertId,
														reviews: reviews)
		let viewController = ReviewsListViewController(viewModel: reviewsListViewModel)
		viewController.hidesBottomBarWhenPushed = true
		self.navigationController?.pushViewController(viewController, animated: true)
	}
}
