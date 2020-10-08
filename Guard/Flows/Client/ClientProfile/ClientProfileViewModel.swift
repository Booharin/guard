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
		view.avatarImageView.clipsToBounds = true
		// title label
		view.titleNameLabel.textAlignment = .center
		view.titleNameLabel.textColor = Colors.mainTextColor
		view.titleNameLabel.font = Saira.bold.of(size: 22)
		view.titleNameLabel.text = "Pary Mason"
		// city label
		view.cityLabel.textAlignment = .center
		view.cityLabel.textColor = Colors.mainTextColor
		view.cityLabel.font = SFUIDisplay.light.of(size: 14)
		view.cityLabel.text = "🇷🇺 Russia, Saint-Petersburg"
		// email label
		view.emailLabel.textAlignment = .center
		view.emailLabel.textColor = Colors.mainTextColor
		view.emailLabel.font = SFUIDisplay.regular.of(size: 15)
		view.emailLabel.text = "booharin@bk.ru"
		// phone label
		view.phoneLabel.textAlignment = .center
		view.phoneLabel.textColor = Colors.mainTextColor
		view.phoneLabel.font = SFUIDisplay.medium.of(size: 18)
		view.phoneLabel.text = "+7(964)-638-19-28"
	}

	func removeBindings() {}
}
