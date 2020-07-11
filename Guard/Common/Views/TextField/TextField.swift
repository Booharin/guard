//
//  TextField.swift
//  Wheels
//
//  Created by Alexandr Bukharin on 23.06.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

final class TextField: UITextField {

	init() {
		super.init(frame: .zero)
		layer.cornerRadius = 10
		layer.borderColor = Colors.borderColor.cgColor
		layer.borderWidth = 0.5
		
		textColor = Colors.borderColor
		
		addOffsets()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func addOffsets() {
		leftView = UIView(frame: CGRect(x: 0,
										y: 0,
										width: 15,
										height: 50))
		leftViewMode = .always

		rightView = UIView(frame: CGRect(x: 0,
										 y: 0,
										 width: 15,
										 height: 50))
		rightViewMode = .always
	}
}
