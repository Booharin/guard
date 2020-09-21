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
			.subscribe(onNext: { _ in
				print("show controller")
			}).disposed(by: disposeBag)
		// avatar
		view.avatarImageView.backgroundColor = .blue
		view.avatarImageView.layer.cornerRadius = 79
		// title label
		view.titleNameLabel.textAlignment = .center
		view.titleNameLabel.textColor = Colors.mainTextColor
		view.titleNameLabel.font = Saira.bold.of(size: 22)
		view.titleNameLabel.text = "Pary Mason"
	}

	func removeBindings() {}
}
