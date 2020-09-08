//
//  FilterButtonView.swift
//  Guard
//
//  Created by Alexandr Bukharin on 06.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

class FilterButtonView: UIView {
	init() {
		super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
		let imageView = UIImageView(frame: CGRect(x: 13, y: 10, width: 24, height: 24))
		imageView.image = #imageLiteral(resourceName: "filter_icn").withRenderingMode(.alwaysTemplate)
		imageView.tintColor = Colors.mainColor
        addSubview(imageView)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
