//
//  FilterViewService.swift
//  Guard
//
//  Created by Alexandr Bukharin on 23.12.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
import RxSwift

protocol HasFilterViewService {
	var filterViewService: FilterViewServiceInterface { get set }
}

protocol FilterViewServiceInterface {
	var selectedIssuesSubject: PublishSubject<[Int]> { get set }
	func showFilterView()
}

final class FilterViewService: FilterViewServiceInterface {
	var selectedIssuesSubject = PublishSubject<[Int]>()
	private var issues = [Int]()
	private var dimmView: UIView?
	private var filterView: UIView?
	private let animationDuration = 0.15
	private let filterViewShowAnimationDuration = 0.35
	private let topOffset: CGFloat = 120
	private var currentOffset: CGFloat = 120
	private var disposeBag = DisposeBag()

	private var currentWindow: UIWindow? {
		return UIApplication.shared.windows.first
	}

	var screenHeight: CGFloat {
		UIScreen.main.bounds.height
	}

	var screenWidth: CGFloat {
		UIScreen.main.bounds.width
	}

	func showFilterView() {
		guard let window = currentWindow else { return }
		// dimm
		dimmView = UIView()
		guard let dimmView = dimmView else { return }
		dimmView.backgroundColor = .clear
		window.addSubview(dimmView)
		dimmView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
//		dimmView
//			.rx
//			.tapGesture()
//			.when(.recognized)
//			.subscribe(onNext: { [weak self] _ in
//				self?.dismissFilterView()
//			}).disposed(by: disposeBag)

		// filter
		filterView = UIView()
		guard let filterView = filterView else { return }
		filterView.layer.cornerRadius = 30
		filterView.backgroundColor = Colors.whiteColor
		dimmView.addSubview(filterView)
		filterView.snp.makeConstraints {
			$0.bottom.equalTo(window.snp.bottom).offset(screenHeight)
			$0.leading.trailing.equalToSuperview()
			$0.height.equalTo(screenHeight)
		}
		filterView
			.rx
			.panGesture()
			.when(.changed)
			.asTranslation()
			.subscribe(onNext: { [weak self] translation, velocity in
				print("Translation yyy = \(translation.y)")
				guard
					let self = self,
					self.currentOffset + translation.y > 120,
					self.currentOffset + translation.y < 300 else { return }

				self.currentOffset += translation.y 
//				filterView.snp.updateConstraints {
//					$0.bottom.equalTo(window.snp.bottom).offset(self.currentOffset)
//				}
				UIView.animate(withDuration: 0.3) {
					self.filterView?.frame.origin.y = self.currentOffset
				}
			}).disposed(by: disposeBag)
		
		filterView
			.rx
			.panGesture()
			.when(.ended)
			.asTranslation()
			.subscribe(onNext: { [weak self] translation, velocity in
				print("Translation=\(translation), velocity=\(velocity)")
				guard
					translation.y > 100,
					let self = self else { return }
				self.dismissFilterView()
			}).disposed(by: disposeBag)

		window.layoutIfNeeded()

		// animate show
		filterView.snp.updateConstraints {
			$0.bottom.equalTo(window.snp.bottom).offset(topOffset)
		}
		UIView.animate(
			withDuration: filterViewShowAnimationDuration,
			delay: 0,
			options: .curveEaseInOut,
			animations: {
				dimmView.backgroundColor = Colors.blackColor.withAlphaComponent(0.6)
				window.layoutIfNeeded()
			}, completion: { _ in
				self.currentOffset = self.filterView?.frame.origin.y ?? 120
			}
		)
	}

	/// Hide alert
	private func dismissFilterView() {
		guard
			let filterView = filterView,
			let dimmView = dimmView,
			let window = currentWindow else { return }

		selectedIssuesSubject.onNext(self.issues)

		filterView.snp.updateConstraints {
			$0.bottom.equalTo(window.snp.bottom).offset(screenHeight)
		}

		UIView.animate(withDuration: filterViewShowAnimationDuration,
					   delay: 0,
					   options: .curveEaseInOut,
					   animations: {
			dimmView.backgroundColor = .clear
			window.layoutIfNeeded()
		}, completion: { _ in
			self.filterView?.removeFromSuperview()
			self.filterView = nil
			self.dimmView?.removeFromSuperview()
			self.dimmView = nil
		})
	}
}
