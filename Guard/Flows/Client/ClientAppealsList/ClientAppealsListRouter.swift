//
//  ClientAppealsListRouter.swift
//  Guard
//
//  Created by Alexandr Bukharin on 11.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxSwift
import RxCocoa

protocol ClientAppealsListRouterProtocol {
    var toAppealDescriptionSubject: PublishSubject<ClientAppeal> { get }
    var toSelectIssueSubject: PublishSubject<Any> { get }
}

final class ClientAppealsListRouter: ClientAppealsListRouterProtocol {
    var navigationController: NavigationController?
    private var disposeBag = DisposeBag()
    var toAppealDescriptionSubject = PublishSubject<ClientAppeal>()
    var toSelectIssueSubject = PublishSubject<Any>()
    
    init() {
        createTransitions()
    }
    
    private func createTransitions() {
        // to appeal description
        toAppealDescriptionSubject
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { _ in
            //
        })
        .disposed(by: disposeBag)
        
        // to select issue & than appeal creating
        toSelectIssueSubject
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { [unowned self] _ in
            self.toSelectIssue()
        })
        .disposed(by: disposeBag)
    }
    
    private func toSelectIssue() {
        let toCreateAppealSubject = PublishSubject<ClientIssue>()
        toCreateAppealSubject
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { clientIssue in
                //
            })
            .disposed(by: disposeBag)

        let selectIssueController = SelectIssueViewController(viewModel:
            SelectIssueViewModel(toCreateAppealSubject: toCreateAppealSubject))
		selectIssueController.hidesBottomBarWhenPushed = true

		self.navigationController?.pushViewController(selectIssueController, animated: true)
    }
}
