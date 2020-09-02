//
//  FontHelper.swift
//  Guard
//
//  Created by Alexandr Bukharin on 27.08.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

enum SFUIDisplay: String {
	case regular = "SFUIDisplay-Regular"
	case medium = "SFUIDisplay-Medium"
	
	func of(size: CGFloat) -> UIFont {
		return UIFont(name: rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
	}
}

enum Saira: String {
	case regular = "Saira-Regular"
	case bold = "Saira-Bold"
	case light = "Saira-Light"
	case medium = "Saira-Medium"
	
	func of(size: CGFloat) -> UIFont {
		return UIFont(name: rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
	}
}
