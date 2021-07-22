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
import MyTrackerSDK
import FBSDKCoreKit
import Alamofire

final class ChooseViewModel:
	ViewModel,
	HasDependencies {

	typealias Dependencies =
		HasRegistrationService &
		HasKeyChainService &
		HasAuthService &
		HasLocalStorageService
	lazy var di: Dependencies = DI.dependencies

	var view: ChooseViewControllerProtocol!
	private let animationDuration = 0.15
	private var disposeBag = DisposeBag()
	let router: ChooseRouter

	init(router: ChooseRouter) {
		self.router = router
	}

	func viewDidSet() {
		// title
		view.titleLabel.text = "choose.title".localized
		view.titleLabel.font = Saira.light.of(size: 25)
		view.titleLabel.textAlignment = .center
		view.titleLabel.textColor = Colors.mainTextColor

		// lawyer button
		view.lawyerEnterView
			.rx
			.tapGesture()
			.when(.recognized)
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
				self.router.toRegistration?(.lawyer)
			}).disposed(by: disposeBag)

		// lawyer title
		view.lawyerTitleLabel.font = Saira.regular.of(size: 22)
		view.lawyerTitleLabel.textColor = Colors.mainTextColor
		view.lawyerTitleLabel.text = "choose.lawyer.enter.button".localized
		
		// lawyer subtitle
		view.lawyerSubtitleLabel.font = Saira.light.of(size: 15)
		view.lawyerSubtitleLabel.textColor = Colors.mainTextColor
		view.lawyerSubtitleLabel.text = "choose.lawyer.enter.button.subtitle".localized
		view.lawyerSubtitleLabel.numberOfLines = 2

		// client button
		view.clientEnterView
			.rx
			.tapGesture()
			.when(.recognized)
			.do(onNext: { [unowned self] _ in
				self.view.loadingView.play()

				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.clientEnterView.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.clientEnterView.alpha = 1
					})
				})
			})
			.flatMap ({ _ -> Observable<Result<Any, AFError>> in
				if self.di.keyChainService.getValue(for: Constants.KeyChainKeys.clientId) == nil {
					return self.di.registrationService.anonimusSignUp()
				} else {
					return self.di.authService.signInById(
						with: self.di.keyChainService.getValue(for: Constants.KeyChainKeys.clientId) ?? ""
					)
				}
			})
			.filter { result in
				switch result {
				case .success:
					return true
				case .failure:
					self.view.loadingView.stop()
					return false
				}
			}
			.map { _ in }
			.flatMap {
				self.di.authService.signInById(
					with: self.di.keyChainService.getValue(for: Constants.KeyChainKeys.clientId) ?? ""
				)
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				self?.view.loadingView.stop()

				let id = "\(self?.di.localStorageService.getCurrenClientProfile()?.id ?? 0)"
				MRMyTracker.trackRegistrationEvent(id)
				AppEvents.logEvent(.completedRegistration)

				switch result {
				case .success:
					self?.router.toMainWithClient?()
				case .failure(let error):
					//TODO: - обработать ошибку
					print(error.localizedDescription)
				}
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
