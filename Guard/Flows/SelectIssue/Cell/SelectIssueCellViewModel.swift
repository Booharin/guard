//
//  SelectIssueCellViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 21.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

struct SelectIssueCellViewModel {
	var title: String
    
    init(itemModel: TableViewItem) {
        self.title = itemModel.title
    }
}
