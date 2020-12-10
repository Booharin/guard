//
//  LawyersListDataSource.swift
//  Guard
//
//  Created by Alexandr Bukharin on 07.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxDataSources
import RxSwift

struct LawyersListDataSource {
	typealias DataSource = RxTableViewSectionedReloadDataSource
	
	static func dataSource(toLawyerSubject: PublishSubject<UserProfile>?) -> DataSource<SectionModel<String, UserProfile>> {
		return .init(configureCell: { dataSource, tableView, indexPath, lawyer -> UITableViewCell in
			
			let cell = LawyerCell()
			cell.viewModel = LawyerCellViewModel(toLawyerSubject: toLawyerSubject,
												 lawyer: lawyer)
			cell.viewModel.assosiateView(cell)
			return cell
		}, titleForHeaderInSection: { dataSource, index in
			return dataSource.sectionModels[index].model
		})
	}
}
