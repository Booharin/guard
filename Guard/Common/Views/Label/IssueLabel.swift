//
//  IssueLabel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 27.12.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
import RxSwift

final class IssueLabel: UILabel {
	private let labelColor: UIColor
	private let animationDuration = 0.15
	private var disposeBag = DisposeBag()
	private var isSelected = false

	init(labelColor: UIColor) {
		self.labelColor = labelColor
		super.init(frame: .zero)
		backgroundColor = Colors.whiteColor
		layer.cornerRadius = 11
		layer.borderWidth = 1
		layer.borderColor = labelColor.cgColor
		clipsToBounds = true
		textColor = labelColor
		font = SFUIDisplay.medium.of(size: 12)
		numberOfLines = 0
		textAlignment = .center

		self
			.rx
			.tapGesture()
			.when(.recognized)
			.subscribe(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.selected(isOn: !self.isSelected)
				})
			}).disposed(by: disposeBag)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func selected(isOn: Bool) {
		if isOn {
			backgroundColor = labelColor
			textColor = Colors.whiteColor
			isSelected = true
		} else {
			backgroundColor = Colors.whiteColor
			textColor = labelColor
			isSelected = false
		}
	}

}
