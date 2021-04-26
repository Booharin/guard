//
//  TitleButtonView.swift
//  Guard
//
//  Created by Alexandr Bukharin on 08.04.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit

final class TitleButtonView: UIView {
	init(title: String) {
		super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
		let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 50))
		addSubview(titleLabel)
		titleLabel.textColor = Colors.mainTextColor
		titleLabel.font = Saira.medium.of(size: 16)
		titleLabel.text = title
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
