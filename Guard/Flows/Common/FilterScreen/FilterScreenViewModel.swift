//
//  FilterScreenViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 01.04.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

final class FilterScreenViewModel:
	NSObject,
	ViewModel,
	HasDependencies {

	var view: FilterScreenViewControllerProtocol!
	private let animationDuration = 0.15

	typealias Dependencies = HasCommonDataNetworkService
	lazy var di: Dependencies = DI.dependencies

	private var filterTitle: String?
	private var subIssuesCodes: [Int]
	private var selectedIssuesSubject: PublishSubject<[Int]>
	private var selectedIssueTypes: [IssueType]?

	private var dataSourceSubject: BehaviorSubject<[SectionModel<String, IssueType>]>?
	private let reloadSubject = PublishSubject<Int>()
	private let markSubIssueSelectedSubject = PublishSubject<SubIssueSelectedModel>()

	private var disposeBag = DisposeBag()

	init(filterTitle: String?,
		 subIssuesCodes: [Int] = [],
		 selectedIssuesSubject: PublishSubject<[Int]>) {
		self.filterTitle = filterTitle
		self.subIssuesCodes = subIssuesCodes
		self.selectedIssuesSubject = selectedIssuesSubject
	}

	func viewDidSet() {
		//appendSelectedIssues()

		view.titleLabel.font = Saira.regular.of(size: 18)
		view.titleLabel.textColor = Colors.mainTextColor
		view.titleLabel.numberOfLines = 0
		view.titleLabel.text = filterTitle
		view.titleLabel.textAlignment = .center

		view.searchTextField.alpha = 0
		view.searchTextField
			.rx
			.text
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [unowned self] text in

				guard
					let text = text,
					!text.isEmpty else {
					selectedIssueTypes = nil
					updateDataSource()
					return
				}

				selectedIssueTypes = di.commonDataNetworkService.issueTypes?.filter {
					if $0.title.containsIgnoringCase(text) || $0.subtitle.containsIgnoringCase(text) {
						return true
					} else {
						let subIssueTypeList = $0.subIssueTypeList?.filter { subIssueType in
							if subIssueType.title.containsIgnoringCase(text) || subIssueType.subtitle.containsIgnoringCase(text) {
								return true
							} else {
								return false
							}
						}

						if subIssueTypeList?.isEmpty ?? true {
							return false
						} else {
							return true
						}
					}
				}

				selectedIssueTypes?.forEach { issueType in
					if let indexOfIssue = selectedIssueTypes?.firstIndex(of: issueType) {
						let array = selectedIssueTypes ?? []
						selectedIssueTypes?[indexOfIssue].subIssueTypeList = array[indexOfIssue].subIssueTypeList?.filter { subIssueType in
							if subIssueType.title.containsIgnoringCase(text) || subIssueType.subtitle.containsIgnoringCase(text) {
								return true
							} else {
								return false
							}
						}
					}
				}

				updateDataSource()

			}).disposed(by: disposeBag)

		view.searchButton.setImage(#imageLiteral(resourceName: "search_icn"), for: .normal)
		view.searchButton.contentMode = .center
		view.searchButton
			.rx
			.tap
			.subscribe(onNext: { [unowned self] _ in
				self.animateTitleSearchChange()
			}).disposed(by: disposeBag)

		view.closeButton.setImage(#imageLiteral(resourceName: "filter_close_icn"), for: .normal)
		view.closeButton.contentMode = .center
		view.closeButton
			.rx
			.tap
			.subscribe(onNext: { [unowned self] _ in
				self.selectedIssuesSubject.onNext(subIssuesCodes)
				self.view.dismiss(animated: true,
								  completion: nil)
			}).disposed(by: disposeBag)

		reloadSubject
			.asObservable()
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [unowned self] issueCode in
				// if searching in progress
				if selectedIssueTypes != nil {
					selectedIssueTypes?.forEach { issueType in
						if issueType.issueCode == issueCode {
							guard let indexOfIssue = selectedIssueTypes?.firstIndex(of: issueType) else { return }
							// find issue section which need to stretch out
							let isSelected = !(selectedIssueTypes?[indexOfIssue].isSelected ?? false)
							selectedIssueTypes?[indexOfIssue].select(on: isSelected)
						}
					}
				}

				// set isSelect for all issue types
				di.commonDataNetworkService.issueTypes?.forEach { issueType in
					if issueType.issueCode == issueCode {
						guard let indexOfIssue = di.commonDataNetworkService.issueTypes?.firstIndex(of: issueType) else { return }
						// find issue section which need to stretch out
						let isSelected = !(di.commonDataNetworkService.issueTypes?[indexOfIssue].isSelected ?? false)
						di.commonDataNetworkService.issueTypes?[indexOfIssue].select(on: isSelected)
					}
				}

				updateDataSource()
			}).disposed(by: disposeBag)

		markSubIssueSelectedSubject
			.asObservable()
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [unowned self] subIssueSelected in
				// if searching in progress
				if selectedIssueTypes != nil {
					selectedIssueTypes?.forEach { issueType in
						let filteredIssues = issueType.subIssueTypeList?.filter { $0.subIssueCode == subIssueSelected.subIssueCode }
						if filteredIssues?.count ?? 0 > 0 {
							// find subIssue which need to select
							guard
								let subIssue = filteredIssues?.first,
								let indexOfIssue = selectedIssueTypes?.firstIndex(of: issueType),
								let indexOfSubIsse = issueType.subIssueTypeList?.firstIndex(of: subIssue) else { return }

							selectedIssueTypes?[indexOfIssue]
								.selectBy(index: indexOfSubIsse,
										  on: subIssueSelected.isSelected)
						}
					}
				}

				di.commonDataNetworkService.issueTypes?.forEach { issueType in
					let filteredIssues = issueType.subIssueTypeList?.filter { $0.subIssueCode == subIssueSelected.subIssueCode }
					if filteredIssues?.count ?? 0 > 0 {
						// find subIssue which need to select
						guard
							let subIssue = filteredIssues?.first,
							let indexOfIssue = di.commonDataNetworkService.issueTypes?.firstIndex(of: issueType),
							let indexOfSubIsse = issueType.subIssueTypeList?.firstIndex(of: subIssue) else { return }

						di.commonDataNetworkService.issueTypes?[indexOfIssue]
							.selectBy(index: indexOfSubIsse,
									  on: subIssueSelected.isSelected)

						updateIssuesCodes(subIssueSelected: subIssueSelected)
					}
				}

				updateDataSource()
			}).disposed(by: disposeBag)

		// table view data source
		let section = SectionModel<String, IssueType>(model: "",
													  items: di.commonDataNetworkService.issueTypes ?? [])
		dataSourceSubject = BehaviorSubject<[SectionModel]>(value: [section])
		dataSourceSubject?
			.bind(to: view.tableView
					.rx
					.items(dataSource: FilterScreenDataSource.dataSource(reloadSubject: reloadSubject,
																		 markSubIssueSelectedSubject: markSubIssueSelectedSubject)))
			.disposed(by: disposeBag)
	}

	private func updateDataSource() {
		let section = SectionModel<String, IssueType>(
			model: "",
			items: selectedIssueTypes == nil ? di.commonDataNetworkService.issueTypes ?? [] : selectedIssueTypes ?? []
		)
		dataSourceSubject?.onNext([section])
	}

//	private func appendSelectedIssues() {
//		di.commonDataNetworkService.issueTypes?
//			.compactMap { $0.subIssueTypeList }
//			.reduce([], +)
//			.forEach { subIssueType in
//				if subIssueType.isSelected == true,
//				   let subIssueCode = subIssueType.subIssueCode {
//					subIssuesCodes.append(subIssueCode)
//				}
//			}
//	}

	private func updateIssuesCodes(subIssueSelected: SubIssueSelectedModel) {
		if subIssueSelected.isSelected == true {
			subIssuesCodes.append(subIssueSelected.subIssueCode)
		} else {
			guard let index = subIssuesCodes.firstIndex(of: subIssueSelected.subIssueCode) else { return }
			subIssuesCodes.remove(at: index)
		}
	}

	private func animateTitleSearchChange() {
		if view.searchTextField.alpha == 0 {
			UIView.animate(withDuration: animationDuration, animations: {
				self.view.titleLabel.alpha = 0
			}, completion: { _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.searchTextField.alpha = 1
				}, completion: { _ in
					self.view.searchTextField.becomeFirstResponder()
				})
			})
		} else {
			UIView.animate(withDuration: animationDuration, animations: {
				self.view.searchTextField.alpha = 0
			}, completion: { _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.titleLabel.alpha = 1
				}, completion: { _ in
					self.view.view.endEditing(true)
				})
			})
		}
	}

	func removeBindings() {}
}
