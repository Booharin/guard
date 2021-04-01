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

final class ClientAppealCellViewModel:
	ViewModel,
	HasDependencies {

	var view: ClientAppealCellProtocol!
	private var disposeBag = DisposeBag()
	let toAppealDescriptionSubject: PublishSubject<ClientAppeal>
	private var clientImageSubject: PublishSubject<Any>?
	let tapSubject = PublishSubject<Any>()
	let animateDuration = 0.15
	let clientAppeal: ClientAppeal

	typealias Dependencies =
		HasClientNetworkService &
		HasLocalStorageService
	lazy var di: Dependencies = DI.dependencies

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
					self.view.containerView.backgroundColor = Colors.lightBlueColor
				}, completion: { _ in
					UIView.animate(withDuration: self.animateDuration, animations: {
						self.view.containerView.backgroundColor = .clear
					})
				})
				self.toAppealDescriptionSubject.onNext(self.clientAppeal)
			}).disposed(by: disposeBag)

		view.appealImageView.layer.cornerRadius = 21
		view.appealImageView.clipsToBounds = true
		view.appealImageView.layer.borderWidth = 1
		view.appealImageView.layer.borderColor = Colors.lightGreyColor.cgColor

		if let image = di.localStorageService.getImage(with: "\(clientAppeal.clientId)_profile_image.jpeg") {
			view.appealImageView.image = image
		} else {
			view.appealImageView.image = #imageLiteral(resourceName: "profile_icn").withRenderingMode(.alwaysTemplate)
			view.appealImageView.tintColor = Colors.lightGreyColor
		}

		// MARK: - If appeel from lawyers appeals list
		if di.localStorageService.getCurrenClientProfile()?.userRole == .lawyer {
			clientImageSubject = PublishSubject<Any>()
			clientImageSubject?
				.asObservable()
				.flatMap { [unowned self] _ in
					self.di.clientNetworkService.getPhoto(profileId: clientAppeal.clientId)
				}
				//.observeOn(MainScheduler.instance)
				.subscribe(onNext: { [weak self] result in
					switch result {
						case .success(let data):
							self?.view.appealImageView.image = UIImage(data: data)
							if let userID = self?.clientAppeal.clientId {
								self?.di.localStorageService.saveImage(data: data,
																	   name: "\(userID)_profile_image.jpeg")
							}
						case .failure(let error):
							print(error.localizedDescription)
					}
				}).disposed(by: disposeBag)
		}

		view.titleLabel.text = clientAppeal.title
		view.titleLabel.font = SFUIDisplay.regular.of(size: 16)
		view.titleLabel.textColor = Colors.mainTextColor

		view.descriptionLabel.font = SFUIDisplay.light.of(size: 12)
		view.descriptionLabel.textColor = Colors.subtitleColor
		view.descriptionLabel.text = clientAppeal.appealDescription

		view.dateLabel.font = SFUIDisplay.light.of(size: 10)
		view.dateLabel.textColor = Colors.mainTextColor
		view.dateLabel.text = Date.getCorrectDate(from: clientAppeal.dateCreated, format: "dd.MM.yyyy")
		
		view.timeLabel.font = SFUIDisplay.light.of(size: 10)
		view.timeLabel.textColor = Colors.mainTextColor
		view.timeLabel.text = Date.getCorrectDate(from: clientAppeal.dateCreated, format: "HH:mm")

		clientImageSubject?.onNext(())
	}
	
	func removeBindings() {}
}
