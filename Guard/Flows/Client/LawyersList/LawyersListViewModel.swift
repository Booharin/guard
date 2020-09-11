//
//  LawyersListViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 03.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class LawyersListViewModel: ViewModel, HasDependencies {
	var view: LawyersListViewControllerProtocol!
	private let animationDuration = 0.15
	private var disposeBag = DisposeBag()
    
    private let userProfileDict: [String : Any] = [
        "userType": "lawyer",
        "email": "some@bk.ru",
        "firstName": "Alex",
        "lastName": "Vardanyan",
        "city": "Moscow",
        "rate": 4.4
    ]
    
    private let cities = [
        "cities.moscow".localized
    ]
    
    var lawyers = [UserProfile]()

	typealias Dependencies =
	HasLocationService &
	HasLocalStorageService
	lazy var di: Dependencies = DI.dependencies
	
	let toLawyerSubject: PublishSubject<UserProfile>

	init(toLawyerSubject: PublishSubject<UserProfile>) {
		self.toLawyerSubject = toLawyerSubject
	}

	func viewDidSet() {

        getLawyersFromProfiles()

		// table view data source
		let section = SectionModel<String, UserProfile>(model: "",
														items: lawyers)
		let items = BehaviorSubject<[SectionModel]>(value: [section])
		items
			.bind(to: view.tableView
				.rx
				.items(dataSource: LawyersListDataSource.dataSource(toLawyerSubject: toLawyerSubject)))
			.disposed(by: disposeBag)

		// back button
		view.filterButtonView
			.rx
			.tapGesture()
			.skip(1)
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.filterButtonView.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.filterButtonView.alpha = 1
					})
				})
			})
			.subscribe(onNext: { _ in
				//
			}).disposed(by: disposeBag)
		
		// back button
		view.titleView
			.rx
			.tapGesture()
			.skip(1)
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.titleView.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.titleView.alpha = 1
					})
				})
                self.view.showActionSheet(with: self.cities)
			})
			.subscribe(onNext: { _ in
				//
			}).disposed(by: disposeBag)
		
		view.titleLabel.font = Saira.semiBold.of(size: 16)
		view.titleLabel.textColor = Colors.mainTextColor
		if let profile = di.localStorageService.getProfile() {
			view.titleLabel.text = "\(profile.city)"
		}
	}
	
	func update(with lawyers: [UserProfile]) {
		self.lawyers = lawyers
		DispatchQueue.main.async {
			self.view.tableView.reloadData()
		}
		
		if self.view.tableView.contentSize.height < self.view.tableView.frame.height {
            self.view.tableView.isScrollEnabled = false
		} else {
			self.view.tableView.isScrollEnabled = true
		}
	}
    
    private func getLawyersFromProfiles() {
        let userProfilesArray = [
            userProfileDict,
            userProfileDict,
            userProfileDict,
            userProfileDict,
            userProfileDict,
            userProfileDict,
            userProfileDict,
            userProfileDict,
            userProfileDict,
            userProfileDict,
            userProfileDict,
            userProfileDict,
            userProfileDict,
            userProfileDict,
            userProfileDict
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: userProfilesArray,
                                                      options: .prettyPrinted)
            let profilesResponse = try JSONDecoder().decode([UserProfile].self, from: jsonData)
            self.update(with: profilesResponse)
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
    }
	
	func removeBindings() {}
}
