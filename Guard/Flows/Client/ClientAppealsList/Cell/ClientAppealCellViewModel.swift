//
//  ClientAppealCellViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 09.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxSwift
import RxCocoa

struct ClientAppealCellViewModel: ViewModel {
    var view: ClientAppealCellProtocol!
    private var disposeBag = DisposeBag()
    let toAppealCreateSubject: PublishSubject<Any>
    let animateDuration = 0.15
    let clientAppeal: ClientAppeal

    init(clientAppeal: ClientAppeal, toAppealCreateSubject: PublishSubject<Any>) {
        self.clientAppeal = clientAppeal
        self.toAppealCreateSubject = toAppealCreateSubject
    }

    func viewDidSet() {

    }

    func removeBindings() {}
}
