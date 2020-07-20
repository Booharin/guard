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
		view.titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
		view.titleLabel.textAlignment = .center
		view.titleLabel.textColor = Colors.whiteColor
		
		// client button
		view.clientEnterButton
			.rx
			.tap
			.do(onNext: { [unowned self] _ in
				self.view.clientEnterButton.animateBackground()
			})
			.subscribe(onNext: { [unowned self] _ in
				self.view.toRegistration?(.client)
			}).disposed(by: disposeBag)
		
		// lawyer button
		view.lawyerEnterButton
			.rx
			.tap
			.do(onNext: { [unowned self] _ in
				self.view.lawyerEnterButton.animateBackground()
			})
			.subscribe(onNext: { [unowned self] _ in
				self.view.toRegistration?(.lawyer)
			}).disposed(by: disposeBag)
	}
	func removeBindings() {}
}
