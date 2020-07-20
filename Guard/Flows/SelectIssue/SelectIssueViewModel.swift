//
//  SelectIssueViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 19.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxSwift
import RxCocoa

final class SelectIssueViewModel: ViewModel {
	var view: SelectIssueViewControllerProtocol!
	private var disposeBag = DisposeBag()
	
	func viewDidSet() {}
	
	func removeBindings() {}
}
