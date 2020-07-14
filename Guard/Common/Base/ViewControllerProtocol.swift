//
//  ViewControllerProtocol.swift
//  Guard
//
//  Created by Alexandr Bukharin on 11.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

protocol ViewControllerProtocol {
    func present(_ viewControllerToPresent: UIViewController,
				 animated flag: Bool,
				 completion: (() -> Void)?)
    func dismiss(animated flag: Bool,
				 completion: (() -> Void)? )
    var view: UIView! { get }
	var navController: UINavigationController? { get }
}
