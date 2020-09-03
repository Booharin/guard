//
//  LawyersListViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 03.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class LawyersListViewModel: ViewModel {
	var view: LawyerListViewControllerProtocol!
	private var disposeBag = DisposeBag()
	
	func viewDidSet() {
	}
	
	func removeBindings() {}
}
