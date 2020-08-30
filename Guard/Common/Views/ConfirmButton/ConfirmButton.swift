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

	private let animationDuration = 0.1
	
	init(title: String = "",
		 backgroundColor: UIColor = Colors.buttonDisabledColor,
		 cornerRadius: CGFloat = 25) {
		super.init(frame: .zero)
		
		setTitle(title, for: .normal)
		setTitleColor(Colors.white, for: .normal)
		layer.cornerRadius = cornerRadius
		self.backgroundColor = backgroundColor

		titleEdgeInsets = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: -25)
		contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 48)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func animateBackground() {
		isEnabled = false
		UIView.animate(withDuration: animationDuration, animations: {
			self.alpha = 0.5
		}, completion: { _ in
			UIView.animate(withDuration: self.animationDuration, animations: {
				self.alpha = 1
			}, completion: { _ in
				self.isEnabled = true
			})
		})
	}
}
