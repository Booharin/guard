//
//  BackButtonView.swift
//  Guard
//
//  Created by Alexandr Bukharin on 14.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

class BackButtonView: UIView {
	init() {
		super.init(frame: CGRect(x: 0, y: 0, width: 45, height: 24))
		let imageView = UIImageView(frame: CGRect(x: 15, y: 0, width: 10, height: 18))
        
		imageView.image = #imageLiteral(resourceName: "icn_back_arrow").withRenderingMode(.alwaysTemplate)
		imageView.tintColor = Colors.mainColor
        addSubview(imageView)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
