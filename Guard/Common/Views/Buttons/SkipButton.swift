//
//  SkipButton.swift
//  Guard
//
//  Created by Alexandr Bukharin on 01.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

final class SkipButton: UIButton {
	init(title: String,
		 font: UIFont) {
		super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
		
		let label = UILabel(frame: CGRect(x: -15, y: 15, width: 100, height: 20))
		label.textAlignment = .right
		label.text = title
		label.font = font
		label.textColor = Colors.mainColor
        addSubview(label)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
