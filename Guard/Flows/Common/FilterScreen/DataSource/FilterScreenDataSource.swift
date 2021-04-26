//
//  FilterScreenDataSource.swift
//  Guard
//
//  Created by Alexandr Bukharin on 01.04.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import RxDataSources
import RxSwift

struct FilterScreenDataSource {
	typealias DataSource = RxTableViewSectionedReloadDataSource

	static func dataSource(reloadSubject: PublishSubject<Int>,
						   markSubIssueSelectedSubject: PublishSubject<SubIssueSelectedModel>) -> DataSource<SectionModel<String, IssueType>> {
		return .init(configureCell: { dataSource, tableView, indexPath, issueType -> FilterIssuesCell in

			let cell = FilterIssuesCell()
			cell.viewModel = FilterIssuesCellViewModel(issueType: issueType,
													   reloadSubject: reloadSubject,
													   markSubIssueSelectedSubject: markSubIssueSelectedSubject)
			cell.viewModel?.assosiateView(cell)
			return cell
		}, titleForHeaderInSection: { dataSource, index in
			return dataSource.sectionModels[index].model
		})
	}
}
