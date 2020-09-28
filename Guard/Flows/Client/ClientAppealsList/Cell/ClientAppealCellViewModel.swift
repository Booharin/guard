//
//  ClientAppealCellViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 09.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct ClientAppealCellViewModel: ViewModel {
	var view: ClientAppealCellProtocol!
	private var disposeBag = DisposeBag()
	let toAppealDescriptionSubject: PublishSubject<ClientAppeal>
	let tapSubject = PublishSubject<Any>()
	let animateDuration = 0.15
	let clientAppeal: ClientAppeal

	init(clientAppeal: ClientAppeal, toAppealDescriptionSubject: PublishSubject<ClientAppeal>) {
		self.clientAppeal = clientAppeal
		self.toAppealDescriptionSubject = toAppealDescriptionSubject
	}

	func viewDidSet() {
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
				self.toAppealDescriptionSubject.onNext(self.clientAppeal)
			}).disposed(by: disposeBag)
		
		view.appealImageView.image = #imageLiteral(resourceName: "car_accident_icn")
		
		view.titleLabel.text = clientAppeal.title
		view.titleLabel.font = SFUIDisplay.regular.of(size: 16)
		view.titleLabel.textColor = Colors.mainTextColor
		
		view.descriptionLabel.font = SFUIDisplay.light.of(size: 12)
		view.descriptionLabel.textColor = Colors.subtitleColor
		view.descriptionLabel.text = clientAppeal.appealDescription
		
		view.dateLabel.font = SFUIDisplay.light.of(size: 10)
		view.dateLabel.textColor = Colors.mainTextColor
		view.dateLabel.text = Date.getString(with: clientAppeal.dateCreate, format: "dd.MM.yyyy")
		
		view.timeLabel.font = SFUIDisplay.light.of(size: 10)
		view.timeLabel.textColor = Colors.mainTextColor
		view.timeLabel.text = Date.getString(with: clientAppeal.dateCreate, format: "HH:mm")
	}
	
	func removeBindings() {}
}
