//
//  UITableViewCell+Identifier.swift
//  Guard
//
//  Created by Alexandr Bukharin on 21.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

protocol ReuseIdentifiable {
	static var reuseIdentifier: String { get }
}

extension ReuseIdentifiable {
	static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: ReuseIdentifiable {}
extension UICollectionViewCell: ReuseIdentifiable {}
