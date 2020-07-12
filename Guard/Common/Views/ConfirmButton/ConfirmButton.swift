//
//  ConfirmButton.swift
//  Wheels
//
//  Created by Alexandr Bukharin on 23.06.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
/// Button for confirmation
final class ConfirmButton: UIButton {
	
	private var buttonTitle: String
	private let animationDuration = 0.1
	
	init(title: String = "") {
		buttonTitle = title
		super.init(frame: .zero)
		setTitle(buttonTitle, for: .normal)
		setTitleColor(Colors.borderColor, for: .normal)
		layer.cornerRadius = 10
		backgroundColor = Colors.confirmButton
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func animateBackground() {
		isEnabled = false
		UIView.animate(withDuration: animationDuration, animations: {
			self.backgroundColor = Colors.confirmButtonLight
		}, completion: { _ in
			UIView.animate(withDuration: self.animationDuration, animations: {
				self.backgroundColor = Colors.confirmButton
			}, completion: { _ in
				self.isEnabled = true
			})
		})
	}
}
