//
//  ConversationsListDataSource.swift
//  Guard
//
//  Created by Alexandr Bukharin on 15.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxDataSources
import RxSwift

struct ConversationsListDataSource {
	typealias DataSource = RxTableViewSectionedReloadDataSource

	static func dataSource(toChat: PublishSubject<ChatConversation>) -> DataSource<SectionModel<String, ChatConversation>> {
		return .init(configureCell: { dataSource, tableView, indexPath, conversation -> UITableViewCell in
			
			let cell = ConversationCell()
			cell.viewModel = ConversationCellViewModel(chatConversation: conversation,
													   toChat: toChat)
			cell.viewModel.assosiateView(cell)
			return cell
		}, titleForHeaderInSection: { dataSource, index in
			return dataSource.sectionModels[index].model
		})
	}
}
