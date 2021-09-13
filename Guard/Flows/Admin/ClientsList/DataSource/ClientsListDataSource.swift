//
//  ClientsListDataSource.swift
//  Guard
//
//  Created by Alexandr Bukharin on 12.09.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import RxDataSources
import RxSwift

struct ClientsListDataSource {
    typealias DataSource = RxTableViewSectionedReloadDataSource
    
    static func dataSource(toClientSubject: PublishSubject<UserProfile>?) -> DataSource<SectionModel<String, UserProfile>> {
        return .init(configureCell: { dataSource, tableView, indexPath, client -> UITableViewCell in
            
            let cell = ClientCell()
            cell.viewModel = ClientCellViewModel(toClientSubject: toClientSubject,
                                                 client: client)
            cell.viewModel.assosiateView(cell)
            return cell
        }, titleForHeaderInSection: { dataSource, index in
            return dataSource.sectionModels[index].model
        })
    }
}
