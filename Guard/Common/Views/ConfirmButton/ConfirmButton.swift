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
		 cornerRadius: CGFloat = 25,
		 image: UIImage? = nil) {
		super.init(frame: .zero)
		layer.cornerRadius = cornerRadius
		self.backgroundColor = backgroundColor
		
		// image
		if let image = image {
			tintColor = Colors.mainColor
			setImage(image, for: .normal)
			layer.borderColor = Colors.mainColor.cgColor
			layer.borderWidth = 1
			imageView?.contentMode = .scaleAspectFit
			contentEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
		} else {
			// title
			setTitle(title, for: .normal)
			titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)//SFUIDisplay.medium.of(size: 15)
			setTitleColor(Colors.whiteColor, for: .normal)
			titleEdgeInsets = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: -25)
			contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 48)
		}
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
