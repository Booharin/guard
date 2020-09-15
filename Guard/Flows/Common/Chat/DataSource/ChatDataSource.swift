//
//  ChatDataSource.swift
//  Guard
//
//  Created by Alexandr Bukharin on 15.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxDataSources
import RxSwift

struct ChatDataSource {
    typealias DataSource = RxTableViewSectionedReloadDataSource
    
	static func dataSource(toLawyerSubject: PublishSubject<UserProfile>) -> DataSource<SectionModel<String, ChatMessage>> {
        return .init(configureCell: { dataSource, tableView, indexPath, chatMessage -> UITableViewCell in
            
            let cell = ChatCell()
			cell.viewModel = ChatCellViewModel(chatMessage: chatMessage)
			cell.viewModel.assosiateView(cell)
            return cell
        }, titleForHeaderInSection: { dataSource, index in
			return dataSource.sectionModels[index].model
        })
    }
}
