//
//  FilterScreenModuleFactory.swift
//  Guard
//
//  Created by Alexandr Bukharin on 01.04.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit.UIViewController
import RxSwift

final class FilterScreenModuleFactory {
	static func createModule(filterTitle: String? = "filter.title".localized,
							 subIssuesCodes: [Int],
							 selectedIssuesSubject: PublishSubject<[Int]>) -> UIViewController {
		let viewModel = FilterScreenViewModel(filterTitle: filterTitle,
											  subIssuesCodes: subIssuesCodes,
											  selectedIssuesSubject: selectedIssuesSubject)
		let controller = FilterScreenViewController(viewModel: viewModel)
		controller.modalPresentationStyle = .fullScreen
		return controller
	}
}
