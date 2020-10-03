//
//  SelectIssueViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 19.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

final class SelectIssueViewModel: ViewModel {
	var view: SelectIssueViewControllerProtocol!
	private var disposeBag = DisposeBag()
	private let animationDuration = 0.15
	var toMainSubject: PublishSubject<IssueType>?
	var toCreateAppealSubject: PublishSubject<IssueType>?

	init(toMainSubject: PublishSubject<IssueType>? = nil,
		 toCreateAppealSubject: PublishSubject<IssueType>? = nil) {
		self.toMainSubject = toMainSubject
		self.toCreateAppealSubject = toCreateAppealSubject
	}

	var issueTypes = [IssueType]()

	func viewDidSet() {
		getIssueTypesFromServer()
		// back button
		view.backButtonView
			.rx
			.tapGesture()
			.when(.recognized)
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.backButtonView.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.backButtonView.alpha = 1
					})
				})
			})
			.subscribe(onNext: { [weak self] _ in
				self?.view.navController?.popViewController(animated: true)
			}).disposed(by: disposeBag)
		// title
		view.titleLabel.font = Saira.regular.of(size: 18)
		view.titleLabel.textColor = Colors.mainTextColor
		view.titleLabel.text = "new_appeal.title".localized

		// header
		view.headerTitleLabel.textColor = Colors.mainTextColor
		view.headerTitleLabel.textAlignment = .center
		view.headerSubtitleLabel.textColor = Colors.mainTextColor
		view.headerSubtitleLabel.textAlignment = .center
		view.headerSubtitleLabel.font = Saira.light.of(size: 18)

		if toMainSubject == nil {
			view.headerTitleLabel.font = Saira.light.of(size: 15)
			view.headerTitleLabel.text = "new_appeal.header.title".localized
			view.headerSubtitleLabel.text = "new_appeal.header.subtitle".localized
		} else {
			view.headerTitleLabel.font = Saira.light.of(size: 25)
			view.headerTitleLabel.text = "client.issue.header.title".localized
			view.headerSubtitleLabel.text = "client.issue.header.subtitle".localized
		}

		let section = SectionModel<String, IssueType>(model: "",
														items: issueTypes)
		let items = BehaviorSubject<[SectionModel]>(value: [section])
		items
			.bind(to: view.tableView
					.rx
					.items(dataSource: SelectIssueDataSource.dataSource(toMainSubject: toMainSubject,
																		toCreateAppealSubject: toCreateAppealSubject)))
			.disposed(by: disposeBag)
		
		// swipe to go back
		view.view
			.rx
			.swipeGesture(.right)
			.when(.recognized)
			.subscribe(onNext: { [unowned self] _ in
				if self.toMainSubject == nil {
					self.view.navController?.popViewController(animated: true)
				}
			}).disposed(by: disposeBag)
	}

	private func getIssueTypesFromServer() {
		do {
			let jsonData = try JSONSerialization.data(withJSONObject: issuesDict,
													  options: .prettyPrinted)
			let issueTypesResponse = try JSONDecoder().decode(IssuesResponse.self, from: jsonData)
			self.update(with: issueTypesResponse.issuesTypes)
		} catch {
			#if DEBUG
			print(error)
			#endif
		}
	}

	func update(with issueTypes: [IssueType]) {
		self.issueTypes = issueTypes
		DispatchQueue.main.async {
			self.view.tableView.reloadData()
		}
		
		if self.view.tableView.contentSize.height < self.view.tableView.frame.height {
			self.view.tableView.isScrollEnabled = false
		} else {
			self.view.tableView.isScrollEnabled = true
		}
	}

	func removeBindings() {}
}

let issuesDict = [
	"issuesTypes": [
		["title": "Гражданское право",
		 "subtitle": "Расторжение брака, наследство, страхование, заключение договоров, сопровождение юр.лиц, финансы, налоги, строительство",
		 "issueCode": "CIVIC",
		 "subtypes": [
			["title": "Семейное право",
			 "subtitle": "Расторжение брака, брачный договор, раздел имущества, алименты, порядок общения с ребенком",
			 "issueCode": "FAMILY"],
			["title": "Наследственное право",
			 "subtitle": "Вступление в наследство, составление завещания, недостойный наследник, раздел наследства",
			 "issueCode": "INHERITANCE"],
			["title": "Страхование",
			 "subtitle": "Страхование имущества, КАСКО, ОСАГО, страхование жизни, перестрахование",
			 "issueCode": "INSURANCE"],
			["title": "Договорное право",
			 "subtitle": "Заключение, расторжение, изменение договоров",
			 "issueCode": "INSURANCE"],
			["title": "Административное право",
			 "subtitle": "Оспаривание штрафов, ДТП",
			 "issueCode": "ADMINISTRATIVE"],
			["title": "Трудовое право",
			 "subtitle": "Разрешение трудовых споров, материальная ответственность, прием на работу, увольнение",
			 "issueCode": "WORK"],
			["title": "Корпоративное право",
			 "subtitle": "Создание, сопровождение, ликвидация, банкротство юрлиц",
			 "issueCode": "CORPORATE"],
			["title": "Финансовое право",
			 "subtitle": "Налоги, имущественный вычет, инвестиции, урегулирование отношений между банком и клиентом",
			 "issueCode": "FINANCIAL"],
			["title": "Земельное право",
			 "subtitle": "Сделки с землей, сервитут, межевание земель, изменение назначение земли",
			 "issueCode": "LAND"],
			["title": "Жилищное право",
			 "subtitle": "Сделки с недвижимостью, переустройство, перепланировка",
			 "issueCode": "HOUSE"],
			["title": "Строительство",
			 "subtitle": "",
			 "issueCode": "BUILDING"],
			["title": "Авторское и патентное право",
			 "subtitle": "Нарушение авторского права, оформление патента на авторское право",
			 "issueCode": "AUTHOR"]
		 ]],
		["title": "Уголовное право",
		 "subtitle": "Наркотики, убийство, кража, мошенничество, телесные повреждения, взятка",
		 "issueCode": "CRIMINAL",
		 "subtypes": [
			["title": "Против жизни и здоровья",
			 "subtitle": "Наркотики, убийство, телесные повреждения, износилование",
			 "issueCode": "AGAINST_LIFE"],
			["title": "Против собственности",
			 "subtitle": "Хищение, кража, мошенничество, разбой, грабеж, присвоение, вымогательство",
			 "issueCode": "AGAINST_PROPERTY"],
			["title": "Против свободы, чести и достоинства личности",
			 "subtitle": "Похищение человека, Торговля людьми, клевета, оскорбление",
			 "issueCode": "AGAINST_FREEDOM"],
			["title": "Против конституционных прав и свобод",
			 "subtitle": "Нарушение неприкосновенности частной жизни, тайна переписки, нарушение неприкосновенности жилища",
			 "issueCode": "AGAINST_PRIVACY"],
			["title": "Против общественной безопасности",
			 "subtitle": "бандитизм, массовые беспорядки, вандализм",
			 "issueCode": "AGAINST_PRIVACY"],
			["title": "Должностные",
			 "subtitle": "Злоупотребление властью или служебным положением, превышение власти или служебных полномочий, дача, получение взятки и посредничество во взяточничестве",
			 "issueCode": "BRIBE"],
			["title": "Государственные",
			 "subtitle": "Диверсия террористического акта, Пропаганда войны, национальный розни, шпионаж",
			 "issueCode": "AGAINST_STATE"],
			["title": "Хозяйственные",
			 "subtitle": "Незаконная охота, рыбная ловля, занятие запрещенным промыслом",
			 "issueCode": "AGAINST_NATURE"],
			["title": "Против правосудия",
			 "subtitle": "Заведомо ложный донос, Заведомо незаконный арест или задержание",
			 "issueCode": "AGAINST_JUSTICE"],
			["title": "Против порядка управления",
			 "subtitle": "Сопротивление представителю власти, Оскорбление работника правоохранительных органов",
			 "issueCode": "AGAINST_GOVERNMENT"],
			["title": "Воинские",
			 "subtitle": "Дезертирство, мародёрство, неповиновение",
			 "issueCode": "AGAINST_MILITARY"]
		 ]]
	]
]

