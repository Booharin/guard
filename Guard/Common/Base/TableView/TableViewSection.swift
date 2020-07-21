//
//  TableViewSection.swift
//  Guard
//
//  Created by Alexandr Bukharin on 21.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxDataSources

struct TableViewSection {
    var items: [TableViewItem]
    let header: String
    
    init(items: [TableViewItem], header: String) {
        self.items = items
        self.header = header
    }
}

extension TableViewSection: SectionModelType {
    typealias Item = TableViewItem
    
    init(original: Self, items: [Self.Item]) {
        self = original
    }
}
