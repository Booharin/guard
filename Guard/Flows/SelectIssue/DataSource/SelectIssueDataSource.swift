//
//  SelectIssueDataSource.swift
//  Guard
//
//  Created by Alexandr Bukharin on 21.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxDataSources

struct SelectIssueDataSource {
    typealias DataSource = RxTableViewSectionedReloadDataSource
    
    static func dataSource() -> DataSource<TableViewSection> {
        return .init(configureCell: { dataSource, tableView, indexPath, item -> UITableViewCell in
            
            let cell = SelectIssueTableViewCell()
            cell.viewModel = SelectIssueCellViewModel(itemModel: item)
            return cell
        }, titleForHeaderInSection: { dataSource, index in
            return dataSource.sectionModels[index].header
        })
    }
}
