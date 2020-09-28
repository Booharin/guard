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
	private let isSeparatorHidden: Bool
	let animateDuration = 0.15
	private var disposeBag = DisposeBag()
	
	init(title: String, isOn: Bool, isSeparatorHidden: Bool) {
		self.title = title
		self.isOn = isOn
		self.isSeparatorHidden = isSeparatorHidden
	}

	func viewDidSet() {
		view.titleLabel.text = title
		view.titleLabel.font = SFUIDisplay.regular.of(size: 16)
		view.titleLabel.textColor = Colors.mainTextColor
		
		view.switcher.setOn(isOn, animated: false)
		view.switcher.isUserInteractionEnabled = true

		view.separatorView.backgroundColor = Colors.separatorColor
		view.separatorView.isHidden = isSeparatorHidden
	}

	func removeBindings() {}
}
