//
//  ChooseViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 15.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxSwift
import RxCocoa
import RxGesture

final class ChooseViewModel: ViewModel {
	var view: ChooseViewControllerProtocol!
	private let animationDuration = 0.15
	private var disposeBag = DisposeBag()
	
	func viewDidSet() {
		// title
		view.titleLabel.text = "choose.title".localized
		view.titleLabel.font = Saira.light.of(size: 25)
		view.titleLabel.textAlignment = .center
		view.titleLabel.textColor = Colors.maintextColor
		
		// lawyer button
		view.lawyerEnterView
			.rx
			.tapGesture()
			.skip(1)
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.lawyerEnterView.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.lawyerEnterView.alpha = 1
					})
				})
			})
			.subscribe(onNext: { [unowned self] _ in
				self.view.toRegistration?(.lawyer)
			}).disposed(by: disposeBag)
		
		// lawyer title
		view.lawyerTitleLabel.font = Saira.regular.of(size: 22)
		view.lawyerTitleLabel.textColor = Colors.maintextColor
		view.lawyerTitleLabel.text = "choose.lawyer.enter.button".localized
		
		// lawyer subtitle
		view.lawyerSubtitleLabel.font = Saira.light.of(size: 15)
		view.lawyerSubtitleLabel.textColor = Colors.maintextColor
		view.lawyerSubtitleLabel.text = "choose.lawyer.enter.button.subtitle".localized
		view.lawyerSubtitleLabel.numberOfLines = 2

		// client button
		view.clientEnterView
			.rx
			.tapGesture()
			.skip(1)
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.clientEnterView.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.clientEnterView.alpha = 1
					})
				})
			})
			.subscribe(onNext: { [unowned self] _ in
				self.view.toRegistration?(.client)
			}).disposed(by: disposeBag)
		
		// lawyer title
		view.clientTitleLabel.font = Saira.regular.of(size: 22)
		view.clientTitleLabel.textColor = Colors.greenColor
		view.clientTitleLabel.text = "choose.client.enter.button".localized
		
		// lawyer subtitle
		view.clientSubtitleLabel.font = Saira.light.of(size: 15)
		view.clientSubtitleLabel.textColor = Colors.greenColor
		view.clientSubtitleLabel.text = "choose.client.enter.button.subtitle".localized
		view.clientSubtitleLabel.numberOfLines = 2

	}

	func removeBindings() {}
}
