//
//  UIScreen+iPhoneType.swift
//  Guard
//
//  Created by Alexandr Bukharin on 30.08.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Foundation

import UIKit

extension UIScreen {
    
    enum DisplayClass {
        case iPhone8
		case iPhone8Plus
		case iPhoneX
		case iPhone11ProMax
    }
    
    static var displayClass: DisplayClass {

        switch UIScreen.main.bounds.size.height {
        case let x where x <= 667:
            return .iPhone8
        case 736:
            return .iPhone8Plus
		case 812:
			return .iPhoneX
		case let x where x >= 896:
			return .iPhone11ProMax
		default:
			return .iPhoneX
		}
    }
}
