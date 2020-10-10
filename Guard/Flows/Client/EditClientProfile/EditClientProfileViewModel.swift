//
//  EditClientProfileViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 10.10.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class EditClientProfileViewModel: ViewModel {
	var view: EditClientProfileViewControllerProtocol!
	private let animationDuration = 0.15
	let userProfile: UserProfile
	private var disposeBag = DisposeBag()

	init(userProfile: UserProfile) {
		self.userProfile = userProfile
	}

	func viewDidSet() {
		// back button
		view.backButton.setImage(#imageLiteral(resourceName: "icn_back_arrow"), for: .normal)
		view.backButton.rx
			.tap
			.subscribe(onNext: { [unowned self] _ in
				self.view.navController?.popViewController(animated: true)
			}).disposed(by: disposeBag)
		// confirm button
		view.confirmButton.setImage(#imageLiteral(resourceName: "confirm_icn"), for: .normal)
		view.confirmButton.rx
			.tap
			.subscribe(onNext: { [unowned self] _ in
				self.view.navController?.popViewController(animated: true)
			}).disposed(by: disposeBag)
		// avatar
		view.avatarImageView.image = #imageLiteral(resourceName: "profile_icn")
		view.avatarImageView.clipsToBounds = true
		// edit view
		view.editPhotoView.backgroundColor = Colors.blackColor.withAlphaComponent(0.5)
		view.editPhotoView.layer.cornerRadius = 38
		view.editPhotoView.rx
			.tapGesture()
			.when(.recognized)
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.editPhotoView.alpha = 0.7
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.editPhotoView.alpha = 1
					})
				})
			})
			.subscribe(onNext: { [unowned self] _ in
				//
			}).disposed(by: disposeBag)
	}
	
	func removeBindings() {}
}
