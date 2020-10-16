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
	private let animationDuration = 0.15
	private var disposeBag = DisposeBag()
	
	typealias Dependencies = HasLocalStorageService
	lazy var di: Dependencies = DI.dependencies
	
	private let conversationDict: [String : Any] = [
		"dateCreated": 1599719845.0,
		"companionId": 0,
		"lastMessage": "Да и нахуй мне нужны такие ваши услуги!"
	]
	
	init(router: ConversationsListRouterProtocol) {
		self.router = router
	}
	
	func viewDidSet() {
		getConversationsFromServer()
		
		// table view data source
		let section = SectionModel<String, ChatConversation>(model: "",
															 items: conversations)
		let items = BehaviorSubject<[SectionModel]>(value: [section])
		items
			.bind(to: view.tableView
					.rx
					.items(dataSource: ConversationsListDataSource.dataSource(toChat: router.toChatSubject)))
			.disposed(by: disposeBag)
		
		// greeting
		view.greetingLabel.font = Saira.light.of(size: 25)
		view.greetingLabel.textColor = Colors.mainTextColor
		view.greetingLabel.textAlignment = .center
		
		if let profile = di.localStorageService.getCurrenClientProfile(),
		   !profile.firstName.isEmpty {
			view.greetingLabel.text = "\("chat.greeting.title".localized), \(profile.firstName)"
		} else {
			view.greetingLabel.text = "chat.greeting.title".localized
		}
		
		view.greetingDescriptionLabel.font = Saira.light.of(size: 18)
		view.greetingDescriptionLabel.textColor = Colors.mainTextColor
		view.greetingDescriptionLabel.textAlignment = .center
		view.greetingDescriptionLabel.text = "chat.greeting.description".localized
	}
	
	private func getConversationsFromServer() {
		let conversationArray = [
			conversationDict,
			conversationDict,
			conversationDict,
			conversationDict,
			conversationDict,
			conversationDict,
			conversationDict,
			conversationDict,
			conversationDict,
			conversationDict,
			conversationDict,
			conversationDict,
			conversationDict,
			conversationDict,
			conversationDict
		]
		do {
			let jsonData = try JSONSerialization.data(withJSONObject: conversationArray,
													  options: .prettyPrinted)
			let conversationsResponse = try JSONDecoder().decode([ChatConversation].self, from: jsonData)
			self.conversations = conversationsResponse
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
				self.view.updateTableView()
			})
		} catch {
			#if DEBUG
			print(error)
			#endif
		}
	}
	
	func removeBindings() {}
}
