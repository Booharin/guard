//
//  ConversationsListViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 15.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

final class ConversationsListViewModel: ViewModel, HasDependencies {
	var view: ConversationsListViewControllerProtocol!
	let router: ConversationsListRouterProtocol
	private var conversations = [ChatConversation]()
	var conversationsListSubject: PublishSubject<Any>?
	private var dataSourceSubject: BehaviorSubject<[SectionModel<String, ChatConversation>]>?
	private let animationDuration = 0.15
	private var disposeBag = DisposeBag()

	typealias Dependencies =
		HasLocalStorageService &
		HasChatNetworkService
	lazy var di: Dependencies = DI.dependencies

	init(router: ConversationsListRouterProtocol) {
		self.router = router
	}

	func viewDidSet() {
		// table view data source
		let section = SectionModel<String, ChatConversation>(model: "",
															 items: conversations)
		let dataSource = ConversationsListDataSource.dataSource(toChat: router.toChatSubject)
		dataSource.canEditRowAtIndexPath = { dataSource, indexPath  in
			return true
		}
		dataSourceSubject = BehaviorSubject<[SectionModel]>(value: [section])
		dataSourceSubject?
			.bind(to: view.tableView
					.rx
					.items(dataSource: dataSource))
			.disposed(by: disposeBag)

		//TODO: - finish up when chat deleting will be ready
		view.tableView.rx.itemDeleted
			.asObservable()
//			.filter { [unowned self] indexPath in
//				indexPath.row < appeals.count
//			}
//			.flatMap { [unowned self] indexPath in
//				self.di.appealsNetworkService.deleteAppeal(id: appeals[indexPath.row].id)
//			}
//			.flatMap { [unowned self] _ in
//				self.di.appealsNetworkService.getClientAppeals(by: di.localStorageService.getCurrenClientProfile()?.id ?? 0)
//			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
//				self?.view.loadingView.stopAnimating()
//				switch result {
//					case .success(let appeals):
//						self?.update(with: appeals)
//					case .failure(let error):
//						//TODO: - обработать ошибку
//						print(error.localizedDescription)
//				}
			}).disposed(by: disposeBag)

		// greeting
		view.greetingLabel.font = Saira.light.of(size: 25)
		view.greetingLabel.textColor = Colors.mainTextColor
		view.greetingLabel.textAlignment = .center

		if let profile = di.localStorageService.getCurrenClientProfile(),
		   let firstName = profile.firstName,
		   !firstName.isEmpty {
			view.greetingLabel.text = "\("chat.greeting.title".localized), \(firstName)"
		} else {
			view.greetingLabel.text = "chat.greeting.title".localized
		}

		view.greetingDescriptionLabel.font = Saira.light.of(size: 18)
		view.greetingDescriptionLabel.textColor = Colors.mainTextColor
		view.greetingDescriptionLabel.textAlignment = .center
		view.greetingDescriptionLabel.text = "chat.greeting.description".localized

		conversationsListSubject = PublishSubject<Any>()
		conversationsListSubject?
			.asObservable()
			.flatMap { [unowned self] _ in
				self.di.chatNetworkService
					.getConversations(with: di.localStorageService.getCurrenClientProfile()?.id ?? 0,
									  isLawyer: di.localStorageService.getCurrenClientProfile()?.userRole == .lawyer ? true : false)
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				self?.view.loadingView.stopAnimating()
				switch result {
					case .success(let conversations):
						self?.update(with: conversations)
					case .failure(let error):
						//TODO: - обработать ошибку
						print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)

		view.loadingView.startAnimating()
	}

	private func update(with conversations: [ChatConversation]) {
		self.conversations = conversations.sorted {
			$0.dateCreated < $1.dateCreated
		}
		let section = SectionModel<String, ChatConversation>(model: "",
															 items: self.conversations)
		dataSourceSubject?.onNext([section])
		
		if self.view.tableView.contentSize.height + 200 < self.view.tableView.frame.height {
			self.view.tableView.isScrollEnabled = false
		} else {
			self.view.tableView.isScrollEnabled = true
		}
	}

	func removeBindings() {}
}
