//
//  SwitcherCellViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 25.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

struct SwitcherCellViewModel: ViewModel {
	var view: SwitcherCellProtocol!
	private let title: String
	private let isOn: Bool
	let animateDuration = 0.15
	private var disposeBag = DisposeBag()
	
	init(title: String, isOn: Bool) {
		self.title = title
		self.isOn = isOn
	}

	func viewDidSet() {
		view.titleLabel.text = title
		view.titleLabel.font = SFUIDisplay.regular.of(size: 16)
		view.titleLabel.textColor = Colors.mainTextColor
	}

	func removeBindings() {}
}
