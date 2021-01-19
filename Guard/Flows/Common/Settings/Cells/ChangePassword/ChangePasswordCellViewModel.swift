//
//  ChangePasswordCellViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 18.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

struct ChangePasswordCellViewModel: ViewModel {
	var view: ChangePasswordCellProtocol!
	let animateDuration = 0.15
	let tapSubject = PublishSubject<Any>()
	let changePasswordSubject: PublishSubject<Any>
	private var disposeBag = DisposeBag()

	init(changePasswordSubject: PublishSubject<Any>) {
		self.changePasswordSubject = changePasswordSubject
	}

	func viewDidSet() {
		view.titleLabel.text = "settings.change_password.title".localized
		view.titleLabel.font = SFUIDisplay.regular.of(size: 16)
		view.titleLabel.textColor = Colors.mainTextColor
		
		view.iconImageView.image = #imageLiteral(resourceName: "icn_right_arrow").withRenderingMode(.alwaysTemplate)
		view.iconImageView.tintColor = Colors.mainColor

		view.containerView
			.rx
			.tapGesture()
			.when(.recognized)
			.subscribe(onNext: { _ in
				UIView.animate(withDuration: self.animateDuration, animations: {
					self.view.containerView.backgroundColor = Colors.cellSelectedColor
				}, completion: { _ in
					UIView.animate(withDuration: self.animateDuration, animations: {
						self.view.containerView.backgroundColor = .clear
					})
				})
				self.changePasswordSubject.onNext(())
			}).disposed(by: disposeBag)

		view.separatorView.backgroundColor = Colors.separatorColor
	}

	func removeBindings() {}
}
