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
	func showFilterView(with selectedIssues: [Int])
}

final class FilterViewService: FilterViewServiceInterface, HasDependencies {
	var selectedIssuesSubject = PublishSubject<[Int]>()
	private var issues = [Int]()
	private var dimmView: UIView?
	private var filterView: UIView?
	private let animationDuration = 0.15
	private let filterViewShowAnimationDuration = 0.35
	private let topOffset: CGFloat = 120
	private var currentOffset: CGFloat = 120
	private var issueLabels = [IssueLabel]()
	typealias Dependencies = HasCommonDataNetworkService
	lazy var di: Dependencies = DI.dependencies
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

	func showFilterView(with selectedIssues: [Int]) {
		guard let window = currentWindow else { return }
		// dimm
		dimmView = UIView()
		guard let dimmView = dimmView else { return }
		dimmView.backgroundColor = .clear
		window.addSubview(dimmView)
		dimmView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}

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

		// title
		let titleLabel = UILabel()
		filterView.addSubview(titleLabel)
		titleLabel.snp.makeConstraints {
			$0.top.equalTo(filterView.snp.top).offset(37)
			$0.centerX.equalToSuperview()
			$0.height.equalTo(18)
		}
		titleLabel.font = SFUIDisplay.bold.of(size: 15)
		titleLabel.textColor = Colors.mainTextColor
		titleLabel.text = "filter.title".localized

		// close image
		let closeImageView = UIImageView(image: #imageLiteral(resourceName: "filter_close_icn").withRenderingMode(.alwaysTemplate))
		closeImageView.tintColor = Colors.mainColor
		filterView.addSubview(closeImageView)
		closeImageView.snp.makeConstraints {
			$0.width.height.equalTo(60)
			$0.top.equalToSuperview().offset(15)
			$0.trailing.equalToSuperview().offset(-13)
		}
		closeImageView.contentMode = .center
		// back button
		closeImageView
			.rx
			.tapGesture()
			.when(.recognized)
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					closeImageView.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						closeImageView.alpha = 1
					})
				})
			})
			.subscribe(onNext: { [unowned self] _ in
				self.dismissFilterView()
			}).disposed(by: disposeBag)

		let issuesSectionTitle = UILabel()
		issuesSectionTitle.textColor = Colors.mainTextColor
		issuesSectionTitle.font = SFUIDisplay.light.of(size: 18)
		issuesSectionTitle.numberOfLines = 0
		issuesSectionTitle.text = "filter.byIssue".localized
		filterView.addSubview(issuesSectionTitle)
		issuesSectionTitle.snp.makeConstraints {
			$0.leading.equalToSuperview().offset(35)
			$0.top.equalToSuperview().offset(100)
			$0.height.equalTo(21)
		}

		createContainer(with: selectedIssues)

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

		self.issues = issueLabels.compactMap { $0.isSelected ? $0.subIssueCode : nil }

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

	private func createContainer(with selectedIssues: [Int]) {
		let containerView = UIView()
		let containerWidth = screenWidth - 75
		var topOffset = 0
		var currentLineWidth: CGFloat = 0
		filterView?.addSubview(containerView)
		containerView.snp.makeConstraints {
			$0.top.equalToSuperview().offset(151)
			$0.leading.equalToSuperview().offset(35)
			$0.trailing.equalToSuperview().offset(-35)
			$0.height.equalTo(23)
		}

		issueLabels = []

		di.commonDataNetworkService.issueTypes?
			.compactMap { $0.subIssueTypeList }
			.reduce([], +)
			.forEach { issueType in
				print(issueType.title)
				print(issueType.subIssueCode ?? 0)
				let label = IssueLabel(labelColor: Colors.issueLabelColor,
									   subIssueCode: issueType.subIssueCode ?? 0,
									   isSelectable: true)
				label.text = issueType.title
				// calculate correct size of label
				let labelWidth = issueType.title.width(withConstrainedHeight: 23,
												font: SFUIDisplay.medium.of(size: 12)) + 20
				let labelHeight = issueType.title.height(withConstrainedWidth: containerWidth,
												  font: SFUIDisplay.medium.of(size: 12)) + 9
				containerView.addSubview(label)
				label.snp.makeConstraints {
					if currentLineWidth + labelWidth + 10 < containerWidth {
						$0.leading.equalToSuperview().offset(currentLineWidth == 0 ? 0 : currentLineWidth + 10)
						currentLineWidth += labelWidth
					} else {
						$0.leading.equalToSuperview()
						topOffset += (10 + Int(labelHeight))
						currentLineWidth = labelWidth
					}
					$0.top.equalToSuperview().offset(topOffset)
					$0.width.equalTo(labelWidth > containerWidth ? containerWidth : labelWidth)
					$0.height.equalTo(labelHeight)
				}
				// check if there selected issues
				let selectedIssuesSet = Set(selectedIssues)
				if selectedIssuesSet.contains(issueType.subIssueCode ?? 0) {
					label.selected(isOn: true)
				}
				issueLabels.append(label)
			}

		containerView.snp.updateConstraints {
			$0.height.equalTo(topOffset + 23)
		}
	}
}
