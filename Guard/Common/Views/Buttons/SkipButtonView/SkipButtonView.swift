//
//  SkipButtonView.swift
//  Guard
//
//  Created by Alexandr Bukharin on 01.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

class SkipButtonView: UIButton {
	init() {
		super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
		
		let label = UILabel(frame: CGRect(x: -15, y: 15, width: 100, height: 20))
		label.textAlignment = .right
		label.text = "registration.skip.title".localized
		label.font = Saira.light.of(size: 15)
		label.textColor = Colors.mainColor
        addSubview(label)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}