//
//  ReviewsListRouter.swift
//  Guard
//
//  Created by Alexandr Bukharin on 26.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import RxSwift

protocol ReviewsListRouterProtocol {
	var toReviewSubject: PublishSubject<UserReview?> { get }
}

final class ReviewsListRouter: BaseRouter, ReviewsListRouterProtocol {
	var toReviewSubject = PublishSubject<UserReview?>()
	private var disposeBag = DisposeBag()

	override init() {
		super.init()
		createTransitions()
	}

	private func createTransitions() {
		// to review
		toReviewSubject
		.observeOn(MainScheduler.instance)
		.subscribe(onNext: { [unowned self] review in
			self.toReview(with: review)
		})
		.disposed(by: disposeBag)
	}
	
	private func toReview(with review: UserReview?) {
//		let chatViewController = ChatViewController(viewModel: ChatViewModel(chatConversation: conversation))
//		chatViewController.hidesBottomBarWhenPushed = true
//
//		self.navigationController?.pushViewController(chatViewController, animated: true)
	}
}
