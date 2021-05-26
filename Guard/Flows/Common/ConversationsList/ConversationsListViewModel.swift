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

	let conversationsListSubject = PublishSubject<Any>()
	let currentConversationsListUpdateSubject = PublishSubject<Any>()
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

	private var nextPage = 0
	private let pageSize = 20
	private var isAllappealsDownloaded = false

	init(router: ConversationsListRouterProtocol,
		 toChatWithLawyer: PublishSubject<ChatConversation>?) {
		self.router = router
		self.toChatWithLawyer = toChatWithLawyer

		conversationsListSubject
			.asObservable()
			.flatMap { [unowned self] _ in
				self.di.chatNetworkService
					.getConversations(with: currentProfile?.id ?? 0,
									  isLawyer: currentProfile?.userRole == .lawyer ? true : false,
									  page: nextPage,
									  pageSize: pageSize)
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				if let view = self?.view {
					view.loadingView.stop()
				}

				switch result {
					case .success(let conversations):
						self?.update(with: conversations)
					case .failure(let error):
						//TODO: - обработать ошибку
						print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)

		currentConversationsListUpdateSubject
			.asObservable()
			.flatMap { [unowned self] _ in
				self.di.chatNetworkService
					.getConversations(with: currentProfile?.id ?? 0,
									  isLawyer: currentProfile?.userRole == .lawyer ? true : false,
									  page: 0,
									  pageSize: self.pageSize)
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				if let view = self?.view {
					view.loadingView.stop()
				}

				switch result {
					case .success(let conversations):
						self?.conversations.removeAll()
						self?.nextPage = 0
						self?.update(with: conversations)
					case .failure(let error):
						//TODO: - обработать ошибку
						print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(updateConversations),
			name: NSNotification.Name(rawValue: Constants.NotificationKeys.updateMessages),
			object: nil)
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
				self?.view.loadingView.stop()
				switch result {
					case .success(let conversationId):
						guard let index = self?.conversations.firstIndex(where: { $0.id == conversationId }) else { return }
						self?.conversations.remove(at: index)
						let section = SectionModel<String, ChatConversation>(model: "",
																			 items: self?.conversations ?? [])
						self?.dataSourceSubject?.onNext([section])
					case .failure(let error):
						//TODO: - обработать ошибку
						print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)

		view.tableView
			.rx
			.prefetchRows
			.filter { _ in
				self.isAllappealsDownloaded == false
			}
			.subscribe(onNext: { [unowned self] rows in
				if rows.contains([0, 0]) {
					self.conversationsListSubject.onNext(())
				}
			})
			.disposed(by: disposeBag)

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

		view.loadingView.play()

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

		router.updateConversationSubject
			.asObservable()
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] chatConversation in
				if let row = self?.conversations.firstIndex(where: { $0.id == chatConversation.id }) {
					self?.conversations[row] = chatConversation
				} else {
					self?.currentConversationsListUpdateSubject.onNext(())
				}
			}).disposed(by: disposeBag)
	}

	private func update(with conversations: [ChatConversation]) {
		self.conversations.append(
			contentsOf:
				conversations
				.filter {
					!self.conversations.contains($0)
				}
				.sorted {
					$0.dateLastMessage ?? "" > $1.dateLastMessage ?? ""
				}
				.sorted {
					$0.countNotReadMessage ?? 0 > $1.countNotReadMessage ?? 0
				}
		)
		let section = SectionModel<String, ChatConversation>(model: "",
															 items: self.conversations)
		dataSourceSubject?.onNext([section])

		if view != nil {
			if self.view.tableView.contentSize.height + 300 < self.view.tableView.frame.height {
				self.view.tableView.isScrollEnabled = false
			} else {
				self.view.tableView.isScrollEnabled = true
			}
		}

		if conversations.count < pageSize {
			isAllappealsDownloaded = true
		} else {
			nextPage += 1
			isAllappealsDownloaded = false
		}

		updateNotReadCount()
	}

	private func updateNotReadCount() {
		let notReadCount = conversations.compactMap { $0.countNotReadMessage }.reduce(0, +)
		UserDefaults.standard.setValue(notReadCount,
									   forKey: Constants.UserDefaultsKeys.notReadCount)

		let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first

		guard let navController = keyWindow?.rootViewController as? UINavigationController,
			  let tabBarViewController = navController.viewControllers.last as? TabBarController,
			  let tabBarItems = tabBarViewController.tabBar.items else { return }

		if notReadCount > 0 {
			tabBarItems[tabBarItems.count - 2].badgeValue = "1"
			UIApplication.shared.applicationIconBadgeNumber = 1
		} else {
			tabBarItems[tabBarItems.count - 2].badgeValue = nil
			UIApplication.shared.applicationIconBadgeNumber = 0
		}
	}

	@objc private func updateConversations() {
		currentConversationsListUpdateSubject.onNext(())
	}

	func removeBindings() {}
}
