//
//  String+isvalidEmail.swift
//  Guard
//
//  Created by Alexandr Bukharin on 11.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Foundation

extension String {
    var isValidEmail: Bool {
        return NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: self)
    }
}
