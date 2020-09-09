//
//  FontHelper.swift
//  Guard
//
//  Created by Alexandr Bukharin on 27.08.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

enum SFUIDisplay: String {
    case light = "SFUIDisplay-Light"
	case regular = "SFUIDisplay-Regular"
	case medium = "SFUIDisplay-Medium"
    case bold = "SFUIDisplay-Bold"
	
	func of(size: CGFloat) -> UIFont {
		return UIFont(name: rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
	}
}

enum Saira: String {
    case light = "Saira-Light"
	case regular = "Saira-Regular"
	case medium = "Saira-Medium"
    case semiBold = "Saira-SemiBold"
    case bold = "Saira-Bold"
	
	func of(size: CGFloat) -> UIFont {
		return UIFont(name: rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
	}
}
