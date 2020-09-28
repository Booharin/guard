//
//  SettingHeaderCellViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 28.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

struct SettingsHeaderCellViewModel: ViewModel {
	var view: SettingsHeaderCellProtocol!
	private let title: String
	private var disposeBag = DisposeBag()
	
	init(title: String) {
		self.title = title
	}

	func viewDidSet() {
		view.titleLabel.text = title
		view.titleLabel.font = SFUIDisplay.medium.of(size: 15)
		view.titleLabel.textColor = Colors.mainTextColor
	}

	func removeBindings() {}
}
