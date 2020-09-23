//
//  ClientProfileViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 20.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxSwift
import RxCocoa

final class ClientProfileViewModel: ViewModel {
	var view: ClientProfileViewControllerProtocol!
	var router: ClientProfileRouterProtocol
	private var disposeBag = DisposeBag()
	
	init(router: ClientProfileRouterProtocol) {
		self.router = router
	}

	func viewDidSet() {
		view.threedotsButton.setImage(#imageLiteral(resourceName: "Image"), for: .normal)
		view.threedotsButton.rx
			.tap
			.subscribe(onNext: { [unowned self] _ in
				self.view.showActionSheet(toSettingsSubject: self.router.toSettingsSubject)
			}).disposed(by: disposeBag)
		// avatar
		view.avatarImageView.image = #imageLiteral(resourceName: "profile_icn")
		view.avatarImageView.layer.cornerRadius = 79
		view.avatarImageView.clipsToBounds = true
		// title label
		view.titleNameLabel.textAlignment = .center
		view.titleNameLabel.textColor = Colors.mainTextColor
		view.titleNameLabel.font = Saira.bold.of(size: 22)
		view.titleNameLabel.text = "Pary Mason"
	}

	func removeBindings() {}
}
