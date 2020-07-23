//
//  ProfileViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 23.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

final class ProfileViewModel: ViewModel {
	var view: ProfileViewControllerProtocol!
	private var disposeBag = DisposeBag()
	
	func viewDidSet() {
	}
	
	func removeBindings() {}
}
