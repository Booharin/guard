//
//  ReviewsListDataSource.swift
//  Guard
//
//  Created by Alexandr Bukharin on 27.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import RxDataSources
import RxSwift

struct ReviewsListDataSource {
	typealias DataSource = RxTableViewSectionedReloadDataSource

	static func dataSource(toReview: PublishSubject<ReviewDetails>) -> DataSource<SectionModel<String, UserReview>> {
		return .init(configureCell: { dataSource, tableView, indexPath, review -> UITableViewCell in
			
			let cell = ReviewCell()
			cell.viewModel = ReviewCellViewModel(review: review,
												 toReview: toReview)
			cell.viewModel.assosiateView(cell)
			return cell
		}, titleForHeaderInSection: { dataSource, index in
			return dataSource.sectionModels[index].model
		})
	}
}
