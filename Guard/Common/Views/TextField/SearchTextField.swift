//
//  SearchTextField.swift
//  Guard
//
//  Created by Alexandr Bukharin on 08.04.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit

class SearchTextField: UITextField {

	private let placeholderAttributes = [
		NSAttributedString.Key.foregroundColor: Colors.placeholderColor,
		NSAttributedString.Key.font : SFUIDisplay.regular.of(size: 14)
	]

	init(placeHolderTitle: String) {
		super.init(frame: .zero)

		font = SFUIDisplay.regular.of(size: 16)
		textColor = Colors.mainTextColor
		attributedPlaceholder = NSAttributedString(string: placeHolderTitle,
												   attributes: placeholderAttributes)
		// left inset
		leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: frame.height))
		leftViewMode = .always

		//borderStyle = .roundedRect
		layer.cornerRadius = 6
		layer.masksToBounds = true
		layer.borderColor = Colors.textFielfBorderColor.cgColor
		layer.borderWidth = 1
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
