//
//  Date+TimeStamp.swift
//  Guard
//
//  Created by Alexandr Bukharin on 10.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Foundation

extension Date {
    static func getString(with timeStamp: Double, format: String) -> String {
        let date = Date(timeIntervalSince1970: timeStamp)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "MSK")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
}
