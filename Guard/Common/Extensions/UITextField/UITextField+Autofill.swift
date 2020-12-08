//
//  UITextField+Autofill.swift
//  Guard
//
//  Created by Alexandr Bukharin on 29.11.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

extension UITextField {
	func disableAutoFill() {
		if #available(iOS 12, *) {
			textContentType = .oneTimeCode
		} else {
			textContentType = .init(rawValue: "")
		}
	}
}
