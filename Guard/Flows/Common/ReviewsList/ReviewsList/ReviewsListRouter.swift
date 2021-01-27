//
//  ReviewsListRouter.swift
//  Guard
//
//  Created by Alexandr Bukharin on 26.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import RxSwift

protocol ReviewsListRouterProtocol {
	var toReviewSubject: PublishSubject<ReviewDetails> { get }
}

final class ReviewsListRouter: BaseRouter, ReviewsListRouterProtocol {
	var toReviewSubject = PublishSubject<ReviewDetails>()
	private var disposeBag = DisposeBag()

	override init() {
		super.init()
		createTransitions()
	}

	private func createTransitions() {
		// to review
		toReviewSubject
		.observeOn(MainScheduler.instance)
		.subscribe(onNext: { [unowned self] reviewDetails in
			self.toReview(with: reviewDetails)
		})
		.disposed(by: disposeBag)
	}
	
	private func toReview(with details: ReviewDetails) {
		let viewModel = ReviewDetailsViewModel(reviewDetails: details)
		let viewController = ReviewDetailsViewController(viewModel: viewModel)
		viewController.hidesBottomBarWhenPushed = true

		self.navigationController?.pushViewController(viewController, animated: true)
	}
}
