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
	
	init(router: ClientProfileRouterProtocol) {
		self.router = router
	}

	func viewDidSet() {
		
	}

	func removeBindings() {}
}
