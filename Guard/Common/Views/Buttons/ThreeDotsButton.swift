//
//  ThreeDotsButton.swift
//  Guard
//
//  Created by Alexandr Bukharin on 14.10.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

final class ThreeDotsButton: UIButton {
	init() {
		super.init(frame: CGRect(x: 0,
								 y: 0,
								 width: 50,
								 height: 50))
		let imageView = UIImageView(frame: CGRect(x: 15,
												  y: 22,
												  width: 21,
												  height: 5))
		imageView.image = #imageLiteral(resourceName: "three_dots_icn").withRenderingMode(.alwaysTemplate)
		imageView.tintColor = Colors.mainColor
		addSubview(imageView)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
