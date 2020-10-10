//
//  EditTextField.swift
//  Guard
//
//  Created by Alexandr Bukharin on 10.10.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

class EditTextField: UITextField {
	private let placeholderAttributes = [
		NSAttributedString.Key.foregroundColor: Colors.placeholderColor,
		NSAttributedString.Key.font : SFUIDisplay.light.of(size: 15)
	]
	
	private var separatorView = UIView()

	init() {
		super.init(frame: .zero)
		textAlignment = .center
		font = SFUIDisplay.medium.of(size: 15)
		textColor = Colors.mainTextColor
		
		separatorView.backgroundColor = Colors.separatorColor
		addSubview(separatorView)
		separatorView.snp.makeConstraints() {
			$0.width.equalTo(130)
			$0.centerX.equalToSuperview()
			$0.bottom.equalToSuperview()
			$0.height.equalTo(1)
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(placeholderText: String, isSeparatorHidden: Bool = false) {
		attributedPlaceholder = NSAttributedString(string: placeholderText,
												   attributes: placeholderAttributes)
		separatorView.isHidden = isSeparatorHidden
	}
}
