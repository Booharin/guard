//
//  RegistrationViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 14.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxSwift
import RxCocoa
import RxGesture

final class RegistrationViewModel: ViewModel {
	var view: RegistratioViewControllerProtocol!
	private let animationDuration = 0.15
	private var disposeBag = DisposeBag()
	
	func viewDidSet() {
		// back button
		view.backButtonView
		.rx
		.tapGesture()
		.skip(1)
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
		
		// check keyboard showing
        keyboardHeight()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] keyboardHeight in
                if keyboardHeight > 0 {
					self.view.enterButton.snp.updateConstraints() {
						$0.bottom.equalToSuperview().offset(-(keyboardHeight + 30))
					}
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.view.layoutIfNeeded()
					})
				} else {
					self.view.enterButton.snp.updateConstraints() {
						$0.bottom.equalToSuperview().offset(-30)
					}
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.view.layoutIfNeeded()
					})
				}
            })
            .disposed(by: disposeBag)
	}
	
	private func keyboardHeight() -> Observable<CGFloat> {
		return Observable
			.from([
				NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
					.map { notification -> CGFloat in
						(notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
				},
				NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
					.map { _ -> CGFloat in
						0
				}
			])
			.merge()
	}
	func removeBindings() {}
}
