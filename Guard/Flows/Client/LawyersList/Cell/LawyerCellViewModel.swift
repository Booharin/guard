//
//  LawyerCellViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 07.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

final class LawyerCellViewModel:
	ViewModel,
	HasDependencies {

	typealias Dependencies = HasClientNetworkService
	lazy var di: Dependencies = DI.dependencies

	var view: LawyerCellProtocol!

	var toLawyerSubject: PublishSubject<UserProfile>?
	private let lawyerImageSubject = PublishSubject<Any>()
	let tapSubject = PublishSubject<Any>()

	let animateDuration = 0.15
	let lawyer: UserProfile
	private var disposeBag = DisposeBag()

	init(toLawyerSubject: PublishSubject<UserProfile>?,
		 lawyer: UserProfile) {
		self.toLawyerSubject = toLawyerSubject
		self.lawyer = lawyer
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
				self.toLawyerSubject?.onNext(self.lawyer)
			}).disposed(by: disposeBag)

		view.avatarImageView.image = #imageLiteral(resourceName: "profile_icn").withRenderingMode(.alwaysTemplate)
		view.avatarImageView.tintColor = Colors.lightGreyColor
		view.avatarImageView.layer.cornerRadius = 21
		view.avatarImageView.clipsToBounds = true

		view.nameTitle.text = lawyer.fullName
		view.nameTitle.font = SFUIDisplay.regular.of(size: 16)
		view.nameTitle.textColor = Colors.mainTextColor

		view.rateLabel.font = SFUIDisplay.bold.of(size: 15)
		view.rateLabel.textColor = Colors.mainTextColor
		guard let rate = lawyer.averageRate else { return }
		view.rateLabel.text = "\(String(format: "%.1f", rate))"

		lawyerImageSubject
			.asObservable()
			.flatMap { [unowned self] _ in
				self.di.clientNetworkService.getPhoto(profileId: lawyer.id)
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				switch result {
					case .success(let data):
						self?.view.avatarImageView.image = UIImage(data: data)
					case .failure(let error):
						print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)
		lawyerImageSubject.onNext(())
	}

	func removeBindings() {}
}
