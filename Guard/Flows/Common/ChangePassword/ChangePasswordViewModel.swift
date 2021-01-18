//
//  ChangePasswordViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 18.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ChangePasswordViewModel: ViewModel {
	var view: ChangePasswordViewControllerProtocol!
	private var disposeBag = DisposeBag()

	func viewDidSet() {
		 
	}

	func removeBindings() {}
}
