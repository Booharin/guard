//
//  SelectIssueDataSource.swift
//  Guard
//
//  Created by Alexandr Bukharin on 21.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxDataSources
import RxSwift

struct SelectIssueDataSource {
    typealias DataSource = RxTableViewSectionedReloadDataSource
    
	static func dataSource(toMainSubject: PublishSubject<ClientIssue>) -> DataSource<SectionModel<String, ClientIssue>> {
        return .init(configureCell: { dataSource, tableView, indexPath, clientIssue -> UITableViewCell in
            
            let cell = SelectIssueTableViewCell()
			cell.viewModel = SelectIssueCellViewModel(clientIssue: clientIssue,
													  toMainSubject: toMainSubject)
			cell.viewModel.assosiateView(cell)
            return cell
        }, titleForHeaderInSection: { dataSource, index in
			return dataSource.sectionModels[index].model
        })
    }
}
