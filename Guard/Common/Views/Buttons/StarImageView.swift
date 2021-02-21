//
//  StarImageView.swift
//  Guard
//
//  Created by Alexandr Bukharin on 27.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit
import RxSwift

final class StarImageView: UIImageView {
	var isSelected = false
	private let disposeBag = DisposeBag()

	init() {
		super.init(frame: .zero)
		image = #imageLiteral(resourceName: "empty_star_icn").withRenderingMode(.alwaysTemplate)
		tintColor = Colors.mainColor

//		self
//			.rx
//			.tapGesture()
//			.when(.recognized)
//			.subscribe(onNext: { [unowned self] _ in
//				self.selected(isOn: !self.isSelected)
//			}).disposed(by: disposeBag)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func selected(isOn: Bool) {
		isSelected = isOn
		if isOn {
			image = #imageLiteral(resourceName: "full_star_icn").withRenderingMode(.alwaysTemplate)
		} else {
			image = #imageLiteral(resourceName: "empty_star_icn").withRenderingMode(.alwaysTemplate)
		}
	}
}
