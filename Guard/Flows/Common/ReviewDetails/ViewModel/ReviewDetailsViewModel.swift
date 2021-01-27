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
		HasAppealsNetworkService
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

		// title
		view.reviewerName.font = Saira.regular.of(size: 16)
		view.reviewerName.textColor = Colors.mainTextColor
		view.reviewerName.text = senderName ?? "Пользователь"

		// text view
		view.descriptionTextView.isEditable = true
		view.descriptionTextView.textColor = Colors.placeholderColor
		view.descriptionTextView.text = "new_appeal.textview.placeholder".localized
		view.descriptionTextView.font = Saira.light.of(size: 15)
		view.descriptionTextView.textAlignment = .center
		view.descriptionTextView.backgroundColor = Colors.whiteColor
		view.descriptionTextView
			.rx
			.text
			.subscribe(onNext: { [unowned self] _ in
				self.checkAreTextFieldsEmpty()
			}).disposed(by: disposeBag)

		// send button
		view.createReviewButton.isEnabled = false
		view.createReviewButton
			.rx
			.tap
			.do(onNext: { [unowned self] _ in
				self.view.createReviewButton.animateBackground()
				self.view.loadingView.startAnimating()
			})
//			.flatMap { [unowned self] _ in
//				self.di.appealsNetworkService
//					.createAppeal(title: self.view.titleTextField.text ?? "",
//								  appealDescription: self.view.descriptionTextView.text ?? "",
//								  clientId: self.di.localStorageService.getCurrenClientProfile()?.id ?? 0,
//								  issueCode: issueType.subIssueCode ?? 0,
//								  cityCode: self.di.localStorageService.getCurrenClientProfile()?.cityCode?.first ?? 99)
//			}
			.subscribe(onNext: { [weak self] result in
//				self?.view.loadingView.stopAnimating()
//				switch result {
//				case .success:
//					self?.view.navController?.popToRootViewController(animated: true)
//				case .failure(let error):
//					//TODO: - обработать ошибку
//					print(error.localizedDescription)
//				}
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
