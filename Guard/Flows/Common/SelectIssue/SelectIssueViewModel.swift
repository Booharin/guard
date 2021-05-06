//
//  SelectIssueViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 19.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

final class SelectIssueViewModel: ViewModel, HasDependencies {
	typealias Dependencies = HasCommonDataNetworkService
	lazy var di: Dependencies = DI.dependencies

	var view: SelectIssueViewControllerProtocol!
	private let animationDuration = 0.15
	var headerSubtitleHeight: CGFloat = 95

	private var userRole: UserRole?
	var lawyerFirstName: String?

	var toMainSubject: PublishSubject<IssueType>?
	var toCreateAppealSubject: PublishSubject<IssueType>?
	var toSubtypesSubject: PublishSubject<[IssueType]>?
	private var dataSourceSubject: BehaviorSubject<[SectionModel<String, IssueType>]>?
	private var disposeBag = DisposeBag()

	init(toMainSubject: PublishSubject<IssueType>? = nil,
		 toCreateAppealSubject: PublishSubject<IssueType>? = nil,
		 issueTypes: [IssueType]? = nil,
		 userRole: UserRole? = nil,
		 lawyerFirstName: String? = nil) {
		self.toMainSubject = toMainSubject
		self.toCreateAppealSubject = toCreateAppealSubject
		self.issueTypes = issueTypes
		self.userRole = userRole
		self.lawyerFirstName = lawyerFirstName
	}

	var issueTypes: [IssueType]?

	func viewDidSet() {
		// MARK: - take previously saved issue types
		if issueTypes == nil {
			self.issueTypes = di.commonDataNetworkService.issueTypes
			toSubtypesSubject = PublishSubject<[IssueType]>()
			toSubtypesSubject?
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: { [weak self] issueTypes in
					self?.passageToSubtypes(issueTypes: issueTypes)
				})
				.disposed(by: disposeBag)
		}

		// table view data source
		let section = SectionModel<String, IssueType>(model: "",
														items: issueTypes ?? [])
		dataSourceSubject = BehaviorSubject<[SectionModel]>(value: [section])
		dataSourceSubject?
			.bind(to: view.tableView
					.rx
					.items(dataSource: SelectIssueDataSource.dataSource(toMainSubject: toMainSubject,
																		toCreateAppealSubject: toCreateAppealSubject,
																		toSubtyesSubject: toSubtypesSubject)))
			.disposed(by: disposeBag)
		dataSourceSubject?.onNext([section])

		if self.view.tableView.contentSize.height + 100 < self.view.tableView.frame.height {
			self.view.tableView.isScrollEnabled = false
		} else {
			self.view.tableView.isScrollEnabled = true
		}

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
		if lawyerFirstName == nil {
			view.titleLabel.font = Saira.regular.of(size: 18)
			view.titleLabel.textColor = Colors.mainTextColor
			view.titleLabel.text = "new_appeal.title".localized
		}

		// header
		view.headerTitleLabel.textColor = Colors.mainTextColor
		view.headerTitleLabel.textAlignment = .center
		view.headerSubtitleLabel.textColor = Colors.mainTextColor
		view.headerSubtitleLabel.textAlignment = .center
		view.headerSubtitleLabel.font = Saira.light.of(size: 18)
		view.headerSubtitleLabel.numberOfLines = 0
		// select header for to main or to appeal creating
		if toMainSubject == nil {
			view.headerTitleLabel.font = Saira.light.of(size: 15)
			view.headerTitleLabel.text = "new_appeal.header.title".localized
			// select header for to subcategories
			if toSubtypesSubject == nil {
				view.headerSubtitleLabel.text = "new_appeal.header.subcategory.subtitle".localized
				headerSubtitleHeight = 120
			} else {
				view.headerSubtitleLabel.text = "new_appeal.header.subtitle".localized
			}
		} else {
			view.headerTitleLabel.font = Saira.light.of(size: 25)
			view.titleLabel.text = "edit_appeal.title".localized
			// select header for to subcategories
			if toSubtypesSubject == nil {
				view.headerTitleLabel.text = "client.issue.header.subcategory.title".localized
				view.headerSubtitleLabel.text = "client.issue.header.subcategory.subtitle".localized
			} else {
				switch userRole {
				case .client:
					view.headerTitleLabel.text = "client.issue.header.title".localized
					view.headerSubtitleLabel.text = "client.issue.header.subtitle".localized
				case .lawyer:
					if let lawyerName = lawyerFirstName {
						view.headerTitleLabel.text = "\(lawyerName),"
					} else {
						view.headerTitleLabel.text = "lawyer.issue.header.title".localized
					}
					view.headerSubtitleLabel.text = "lawyer.issue.header.subtitle".localized
				default:
					view.headerTitleLabel.text = "client.issue.header.category.title".localized
					break
				}
			}
		}

		// swipe to go back
		view.view
			.rx
			.swipeGesture(.right)
			.when(.recognized)
			.subscribe(onNext: { [unowned self] _ in
				self.view.navController?.popViewController(animated: true)
			}).disposed(by: disposeBag)
	}

	private func passageToSubtypes(issueTypes: [IssueType]) {
		let viewModel = SelectIssueViewModel(toMainSubject: toMainSubject,
											 toCreateAppealSubject: toCreateAppealSubject,
											 issueTypes: issueTypes)
		let selectIssueController = SelectIssueViewController(viewModel: viewModel)
		selectIssueController.hidesBottomBarWhenPushed = true
		self.view.navController?.pushViewController(selectIssueController, animated: true)
	}

	func removeBindings() {}
}

