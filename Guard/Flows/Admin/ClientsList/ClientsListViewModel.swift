//
//  ClientsListViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 12.09.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class ClientsListViewModel: ViewModel, HasDependencies {
    var view: ClientsListViewControllerProtocol!
    private let animationDuration = 0.15
    private var disposeBag = DisposeBag()

    private var clientsListSubject: PublishSubject<Any>?
    private var updateClientsListSubject: PublishSubject<Int>?

    private var router: ClientsListRouterProtocol

    var clients = [UserProfile]()

    private var nextPage = 0
    private let pageSize = 20
    private var isAllappealsDownloaded = false

    typealias Dependencies =
        HasLocationService &
        HasLocalStorageService &
        HasLawyersNetworkService &
        HasCommonDataNetworkService
    lazy var di: Dependencies = DI.dependencies

    private var toClientSubject: PublishSubject<UserProfile>?
    private var dataSourceSubject: BehaviorSubject<[SectionModel<String, UserProfile>]>?

    init(router: ClientsListRouterProtocol) {
        self.router = router
    }

    func viewDidSet() {
        toClientSubject = PublishSubject<UserProfile>()
        toClientSubject?
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { profile in
                self.router.passToClient(with: profile)
            })
            .disposed(by: disposeBag)
        // table view data source
        let section = SectionModel<String, UserProfile>(model: "",
                                                        items: clients)
        dataSourceSubject = BehaviorSubject<[SectionModel]>(value: [section])
        dataSourceSubject?
            .bind(to: view.tableView
                    .rx
                    .items(dataSource: ClientsListDataSource.dataSource(toClientSubject: toClientSubject)))
            .disposed(by: disposeBag)

        view.tableView
            .rx
            .prefetchRows
            .filter { _ in
                self.isAllappealsDownloaded == false
            }
            .subscribe(onNext: { [unowned self] rows in
                if rows.contains([0, 0]) {
                    self.clientsListSubject?.onNext(())
                }
            })
            .disposed(by: disposeBag)

        clientsListSubject = PublishSubject<Any>()
        clientsListSubject?
            .asObservable()
            .flatMap { [unowned self] _ in
                self.di.lawyersNetworkService.getAllClients(page: self.nextPage,
                                                            pageSize: self.pageSize)
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                self?.view.loadingView.stop()
                switch result {
                    case .success(let clients):
                        self?.update(with: clients)
                    case .failure(let error):
                        //TODO: - обработать ошибку
                        print(error.localizedDescription)
                }
            }).disposed(by: disposeBag)

        view.loadingView.play()
        clientsListSubject?.onNext(())
    }

    private func update(with clients: [UserProfile]) {
        self.clients.append(contentsOf: clients)
        let section = SectionModel<String, UserProfile>(model: "",
                                                        items: self.clients)
        dataSourceSubject?.onNext([section])

        if self.view.tableView.contentSize.height + 200 < self.view.tableView.frame.height {
            self.view.tableView.isScrollEnabled = false
        } else {
            self.view.tableView.isScrollEnabled = true
        }


        if clients.isEmpty {
            isAllappealsDownloaded = true
        } else {
            isAllappealsDownloaded = false
        }

        nextPage += 1
    }

    func removeBindings() {}
}

