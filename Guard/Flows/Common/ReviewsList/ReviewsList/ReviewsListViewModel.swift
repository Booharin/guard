//
//  ReviewsListViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 26.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

final class ReviewsListViewModel: ViewModel, HasDependencies {
	var view: ReviewsListViewControllerProtocol!
	private let animationDuration = 0.15
	var reviewsListSubject: PublishSubject<Any>?
	private var dataSourceSubject: BehaviorSubject<[SectionModel<String, UserReview>]>?
	let router: ReviewsListRouterProtocol
	private let userId: Int
	private var reviews = [UserReview]()
	private var isMyReviews = true
	private var disposeBag = DisposeBag()

	typealias Dependencies =
		HasLocalStorageService &
		HasLawyersNetworkService
	lazy var di: Dependencies = DI.dependencies

	init(router: ReviewsListRouterProtocol,
		 isMyReviews: Bool,
		 userId: Int,
		 reviews: [UserReview]) {
		self.router = router
		self.isMyReviews = isMyReviews
		self.userId = userId
		self.reviews = reviews
	}

	func viewDidSet() {
		// table view data source
		let section = SectionModel<String, UserReview>(model: "",
															 items: reviews)
		let dataSource = ReviewsListDataSource.dataSource(toReview: router.toReviewSubject)
		dataSource.canEditRowAtIndexPath = { dataSource, indexPath  in
			return true
		}
		dataSourceSubject = BehaviorSubject<[SectionModel]>(value: [section])
		dataSourceSubject?
			.bind(to: view.tableView
					.rx
					.items(dataSource: dataSource))
			.disposed(by: disposeBag)

		// title
		view.titleLabel.font = SFUIDisplay.bold.of(size: 15)
		view.titleLabel.textColor = Colors.mainTextColor
		view.titleLabel.text = "reviews.title".localized

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

		//MARK: - Add button
		view.addButtonView
			.rx
			.tapGesture()
			.when(.recognized)
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.addButtonView.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.addButtonView.alpha = 1
					})
				})
			})
			.subscribe(onNext: { [unowned self] _ in
				var details = ReviewDetails()
				details.senderId = di.localStorageService.getCurrenClientProfile()?.id
				details.receiverId = userId
				self.router.toReviewSubject.onNext(details)
			}).disposed(by: disposeBag)
		view.addButtonView.isHidden = isMyReviews

		reviewsListSubject = PublishSubject<Any>()
		reviewsListSubject?
			.asObservable()
			.flatMap { [unowned self] _ in
				self.di.lawyersNetworkService.getLawyer(by: self.userId)
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				self?.view.loadingView.stop()
				switch result {
					case .success(let profile):
						self?.update(with: profile.reviewList ?? [])
					case .failure(let error):
						//TODO: - обработать ошибку
						print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)

		update(with: reviews)

		router.reviewCreatedSubject
			.asObservable()
			.subscribe(onNext: { [weak self] _ in
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
					self?.reviewsListSubject?.onNext(())
				}
			}).disposed(by: disposeBag)
	}

	private func update(with reviews: [UserReview]) {
		self.reviews = reviews.sorted {
			$0.dateCreated ?? "" < $1.dateCreated ?? ""
		}
		let section = SectionModel<String, UserReview>(model: "",
													   items: self.reviews)
		dataSourceSubject?.onNext([section])
		
		if self.view.tableView.contentSize.height + 200 < self.view.tableView.frame.height {
			self.view.tableView.isScrollEnabled = false
		} else {
			self.view.tableView.isScrollEnabled = true
		}
	}


	func removeBindings() {}
}
