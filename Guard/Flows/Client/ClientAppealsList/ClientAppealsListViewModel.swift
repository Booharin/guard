//
//  ClientAppealsListViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 09.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxSwift
import RxCocoa

final class ClientAppealsListViewModel: ViewModel {
    var view: ClientAppealsListViewControllerProtocol!
    let toAppealCreateSubject: PublishSubject<Any>
    
    init(toAppealCreateSubject: PublishSubject<Any>) {
        self.toAppealCreateSubject = toAppealCreateSubject
    }

    func viewDidSet() {
        
    }

    func removeBindings() {}
}
