//
//  ConfirmButton.swift
//  Wheels
//
//  Created by Alexandr Bukharin on 23.06.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

final class ConfirmButton: UIButton {
	private var buttonTitle: String
	
	init(title: String = "") {
		buttonTitle = title
		super.init(frame: .zero)
		setTitle(buttonTitle, for: .normal)
		setTitleColor(Colors.borderColor, for: .normal)
		layer.cornerRadius = 5
		backgroundColor = Colors.confirmButton
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
