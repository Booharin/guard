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
	var toChatWithLawyer: PublishSubject<ChatConversation>?

	private let animationDuration = 0.15
	private var disposeBag = DisposeBag()
	private var currentProfile: UserProfile? {
		di.localStorageService.getCurrenClientProfile()
	}

	typealias Dependencies =
		HasLocalStorageService &
		HasChatNetworkService
	lazy var di: Dependencies = DI.dependencies

	init(router: ConversationsListRouterProtocol,
		 toChatWithLawyer: PublishSubject<ChatConversation>?) {
		self.router = router
		self.toChatWithLawyer = toChatWithLawyer
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

		view.tableView.rx.itemDeleted
			.asObservable()
			.filter { [unowned self] indexPath in
				indexPath.row < conversations.count
			}
			.flatMap { [unowned self] indexPath in
				self.di.chatNetworkService.deleteConversation(conversationId: conversations[indexPath.row].id)
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				self?.view.loadingView.stopAnimating()
				switch result {
					case .success:
						self?.conversationsListSubject?.onNext(())
					case .failure(let error):
						//TODO: - обработать ошибку
						print(error.localizedDescription)
				}
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
					.getConversations(with: currentProfile?.id ?? 0,
									  isLawyer: currentProfile?.userRole == .lawyer ? true : false)
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

		toChatWithLawyer?
			.asObservable()
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] chatConversation in
				// check if conversation exist
				var nextConversation: ChatConversation?
				self?.conversations.forEach {
					if $0.userId == chatConversation.userId {
						nextConversation = $0
					}
				}

				// if not exist - create conversation
				if nextConversation == nil {
					self?.router.toChatSubject.onNext(chatConversation)

					// if exist go to this conversation
				} else if let newConversation = nextConversation {
					self?.router.toChatSubject.onNext(newConversation)
				}
			}).disposed(by: disposeBag)

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(updateConversations),
			name: NSNotification.Name(rawValue: Constants.NotificationKeys.updateMessages),
			object: nil)
	}

	private func update(with conversations: [ChatConversation]) {
		self.conversations = conversations.sorted {
			$0.dateCreated < $1.dateCreated
		}
		let section = SectionModel<String, ChatConversation>(model: "",
															 items: self.conversations)
		dataSourceSubject?.onNext([section])
		
		if self.view.tableView.contentSize.height + 300 < self.view.tableView.frame.height {
			self.view.tableView.isScrollEnabled = false
		} else {
			self.view.tableView.isScrollEnabled = true
		}
	}

	@objc private func updateConversations() {
		conversationsListSubject?.onNext(())
	}

	func removeBindings() {}
}
