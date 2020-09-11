//
//  ClientAppealDataSource.swift
//  Guard
//
//  Created by Alexandr Bukharin on 10.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxDataSources
import RxSwift

struct ClientAppealDataSource {
    typealias DataSource = RxTableViewSectionedReloadDataSource
    
    static func dataSource(toAppealDescriptionSubject: PublishSubject<ClientAppeal>) -> DataSource<SectionModel<String, ClientAppeal>> {
        return .init(configureCell: { dataSource, tableView, indexPath, clientAppeal -> UITableViewCell in
            
            let cell = ClientAppealCell()
            cell.viewModel = ClientAppealCellViewModel(clientAppeal: clientAppeal,
                                                       toAppealDescriptionSubject: toAppealDescriptionSubject)
            cell.viewModel.assosiateView(cell)
            return cell
        }, titleForHeaderInSection: { dataSource, index in
            return dataSource.sectionModels[index].model
        })
    }
}
