//
//  DefaultCellViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 21.07.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

struct DefaultCellViewModel: ViewModel {
	var view: DefaultCellProtocol!
	private let animateDuration = 0.15
	private let title: String
	private let actionSubject: PublishSubject<Any>
	private var disposeBag = DisposeBag()

	init(title: String,
		 actionSubject: PublishSubject<Any>) {
		self.title = title
		self.actionSubject = actionSubject
	}

	func viewDidSet() {
		view.titleLabel.text = title
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
					self.view.containerView.backgroundColor = Colors.lightBlueColor
				}, completion: { _ in
					UIView.animate(withDuration: self.animateDuration, animations: {
						self.view.containerView.backgroundColor = .clear
					})
				})
				self.actionSubject.onNext(())
			}).disposed(by: disposeBag)

		view.separatorView.backgroundColor = Colors.separatorColor
	}

	func removeBindings() {}
}
