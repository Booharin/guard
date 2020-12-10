//
//  LawyerProfileViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 10.12.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

protocol LawyerProfileViewModelProtocol {}

final class LawyerProfileViewModel:
	ViewModel,
	LawyerProfileViewModelProtocol,
	HasDependencies {

	typealias Dependencies =
		HasLocalStorageService &
		HasLawyersNetworkService
	lazy var di: Dependencies = DI.dependencies
	var view: LawyerProfileViewControllerProtocol!
	private var disposeBag = DisposeBag()
	private let userProfile: UserProfile

	init(userProfile: UserProfile) {
		self.userProfile = userProfile
	}

	func viewDidSet() {
		
	}

	func removeBindings() {}
}
