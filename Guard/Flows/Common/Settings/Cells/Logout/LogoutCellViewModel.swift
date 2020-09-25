//
//  LogoutCellViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 25.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

struct LogoutCellViewModel: ViewModel {
	var view: LogoutCellProtocol!
	let animateDuration = 0.15
	let tapSubject = PublishSubject<Any>()
	let logoutSubject: PublishSubject<Any>
	private var disposeBag = DisposeBag()

	init(logoutSubject: PublishSubject<Any>) {
		self.logoutSubject = logoutSubject
	}

	func viewDidSet() {
		view.titleLabel.text = "logout.title".localized
		view.titleLabel.font = SFUIDisplay.regular.of(size: 16)
		view.titleLabel.textColor = Colors.mainTextColor
		
		view.iconImageView.image = #imageLiteral(resourceName: "fe_logout").withRenderingMode(.alwaysTemplate)
		view.iconImageView.tintColor = Colors.mainColor
		
		tapSubject
			.subscribe(onNext: { _ in
				UIView.animate(withDuration: self.animateDuration, animations: {
					self.view.containerView.backgroundColor = Colors.cellSelectedColor
				}, completion: { _ in
					UIView.animate(withDuration: self.animateDuration, animations: {
						self.view.containerView.backgroundColor = .clear
					})
				})
				self.logoutSubject.onNext(())
			}).disposed(by: disposeBag)
	}

	func removeBindings() {}
}
