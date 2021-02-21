//
//  ReviewDetailsViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 27.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ReviewDetailsViewModel: ViewModel, HasDependencies {
	var view: ReviewDetailsViewControllerProtocol!
	private let animationDuration = 0.15
	private var disposeBag = DisposeBag()
	private var review: UserReview?
	private var senderId: Int?
	private var receiverId: Int?
	private var senderName: String?

	typealias Dependencies =
		HasLocalStorageService &
		HasAppealsNetworkService &
		HasClientNetworkService
	lazy var di: Dependencies = DI.dependencies

	init(reviewDetails: ReviewDetails) {
		self.review = reviewDetails.review
		self.senderId = reviewDetails.senderId
		self.receiverId = reviewDetails.receiverId
		self.senderName = reviewDetails.senderName
	}

	func viewDidSet() {
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
		view.titleLabel.font = Saira.regular.of(size: 18)
		view.titleLabel.textColor = Colors.mainTextColor
		view.titleLabel.text = "new_review.title".localized
		view.titleLabel.textAlignment = .center

		if review != nil,
		   let rate = review?.rating {
			let roundedRate = Int(rate)
			view.starsStackView.starsViews.indices.forEach { i in
				if i <= roundedRate - 1 {
					view.starsStackView.starsViews[i].selected(isOn: true)
				}
			}
		}

		// title
		view.reviewerName.font = Saira.regular.of(size: 16)
		view.reviewerName.textColor = Colors.mainTextColor
		view.reviewerName.textAlignment = .center

		// text view
		view.descriptionTextView.isEditable = true
		view.descriptionTextView.textColor = Colors.placeholderColor
		view.descriptionTextView.text = "new_review.textview.placeholder".localized
		view.descriptionTextView.font = Saira.light.of(size: 15)
		view.descriptionTextView.textAlignment = .center
		view.descriptionTextView.backgroundColor = Colors.whiteColor
		view.descriptionTextView
			.rx
			.text
			.subscribe(onNext: { [unowned self] _ in
				self.checkAreTextFieldsEmpty()
			}).disposed(by: disposeBag)
		view.descriptionTextView.isEditable = review == nil

		if review != nil {
			view.descriptionTextView.text = review?.reviewDescription
			view.descriptionTextView.textColor = Colors.mainTextColor
			view.descriptionTextView.font = SFUIDisplay.regular.of(size: 16)
		}

		if review != nil {
			view.reviewerName.isHidden = false
			view.reviewerName.text = senderName
		}

		// send button
		view.createReviewButton.isHidden = review != nil
		view.createReviewButton.isEnabled = false
		view.createReviewButton
			.rx
			.tap
			.do(onNext: { [unowned self] _ in
				self.view.createReviewButton.animateBackground()
				self.view.loadingView.play()
			})
			.flatMap { [unowned self] _ in
				self.di.clientNetworkService.reviewUpload(reviewDescription: self.view.descriptionTextView.text,
														  rating: self.view.starsStackView.selectedCount,
														  senderId: self.senderId ?? 0,
														  receiverId: self.receiverId ?? 0)
			}
			.subscribe(onNext: { [weak self] result in
				self?.view.loadingView.stop()
				switch result {
				case .success:
					self?.view.navController?.popToRootViewController(animated: true)
				case .failure(let error):
					//TODO: - обработать ошибку
					print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)

		// MARK: - Check keyboard showing
		keyboardHeight()
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [unowned self] keyboardHeight in
				if keyboardHeight > 0 {
					guard self.view.descriptionTextView.textColor == Colors.mainTextColor else { return }
					self.view.descriptionTextView.contentInset = UIEdgeInsets(top: 0,
																			  left: 0,
																			  bottom: keyboardHeight,
																			  right: 0)
				} else {
					self.view.descriptionTextView.contentInset = UIEdgeInsets(top: 0,
																			  left: 0,
																			  bottom: 0,
																			  right: 0)
				}
			})
			.disposed(by: disposeBag)
	}

	private func checkAreTextFieldsEmpty() {
		guard let description = view.descriptionTextView.text else { return }

		if !description.isEmpty {
			view.createReviewButton.isEnabled = true
			view.createReviewButton.backgroundColor = Colors.greenColor
		} else {
			view.createReviewButton.isEnabled = false
			view.createReviewButton.backgroundColor = Colors.buttonDisabledColor
		}
	}

	private func keyboardHeight() -> Observable<CGFloat> {
		return Observable
			.from([
				NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
					.map { notification -> CGFloat in
						(notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
				},
				NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
					.map { _ -> CGFloat in
						0
				}
			])
			.merge()
	}

	func removeBindings() {}
}
