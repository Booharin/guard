//
//  AddButtonView.swift
//  Guard
//
//  Created by Alexandr Bukharin on 09.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

final class AddButtonView: UIView {
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        let imageView = UIImageView(frame: CGRect(x: 12, y: 9, width: 26, height: 26))
        imageView.image = #imageLiteral(resourceName: "add_appeal_icn").withRenderingMode(.alwaysTemplate)
        imageView.tintColor = Colors.mainColor
        addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
