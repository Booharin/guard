//
//  TextField.swift
//  Wheels
//
//  Created by Alexandr Bukharin on 23.06.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

final class TextField: UITextField {
	
	var alertLabel = UILabel()

	init() {
		super.init(frame: .zero)
		layer.cornerRadius = 10
		layer.sublayerTransform = CATransform3DMakeTranslation(15, 0, 0)
		
		backgroundColor = Colors.textFieldEmptyBackground
		
		textColor = Colors.whiteColor
		tintColor = Colors.borderColor
		
		alertLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
		alertLabel.textColor = Colors.warningColor
		addSubview(alertLabel)
		alertLabel.snp.makeConstraints() {
			$0.top.equalToSuperview().offset(55)
			$0.leading.equalToSuperview().offset(4)
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
