//
//  String+withoutExtraSpaces.swift
//  Guard
//
//  Created by Alexandr Bukharin on 11.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Foundation

extension String {
    var withoutExtraSpaces: String {
        let string = self.replacingOccurrences(of: "^\\s+|\\s+|\\s+$",
                                               with: " ",
                                               options: .regularExpression)
        return string.trimmingCharacters(in: .whitespaces)
    }
}
