//
//  ReviewCellViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 27.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import RxSwift
import UIKit

final class ReviewCellViewModel: ViewModel, HasDependencies {
	var view: ReviewCellProtocol!
	let animateDuration = 0.15
	let review: UserReview
	let toReview: PublishSubject<UserReview?>
	let tapSubject = PublishSubject<Any>()

	typealias Dependencies = HasLocalStorageService
	lazy var di: Dependencies = DI.dependencies

	private var disposeBag = DisposeBag()

	init(review: UserReview,
		 toReview: PublishSubject<UserReview?>) {
		self.review = review
		self.toReview = toReview
	}

	func viewDidSet() {
		view.containerView
			.rx
			.tapGesture()
			.when(.recognized)
			.subscribe(onNext: { _ in
				UIView.animate(withDuration: self.animateDuration, animations: {
					self.view.containerView.backgroundColor = Colors.lightBlueColor
				}, completion: { _ in
					UIView.animate(withDuration: self.animateDuration, animations: {
						self.view.containerView.backgroundColor = .clear
					})
				})
				self.toReview.onNext(self.review)
			}).disposed(by: disposeBag)

		view.avatarImageView.image = #imageLiteral(resourceName: "tab_profile_icn")

		view.nameTitleLabel.text = "Пользователь"
		view.nameTitleLabel.font = SFUIDisplay.regular.of(size: 16)
		view.nameTitleLabel.textColor = Colors.mainTextColor

		view.descriptionLabel.font = SFUIDisplay.light.of(size: 12)
		view.descriptionLabel.textColor = Colors.subtitleColor
		view.descriptionLabel.text = review.reviewDescription

		view.dateLabel.font = SFUIDisplay.light.of(size: 10)
		view.dateLabel.textColor = Colors.mainTextColor
		view.dateLabel.text = Date.getCorrectDate(from: review.dateCreated, format: "dd.MM.yyyy")

		view.rateLabel.font = SFUIDisplay.bold.of(size: 15)
		view.rateLabel.textColor = Colors.mainTextColor
		view.rateLabel.text = "\(String(format: "%.1f", review.rating))"
	}
	func removeBindings() {}
}
