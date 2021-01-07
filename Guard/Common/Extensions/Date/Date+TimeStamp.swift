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

	static func getCorrectDate(from dateString: String, format: String) -> String? {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		guard let date = dateFormatter.date(from: dateString) else { return nil }
		dateFormatter.dateFormat = format
		return dateFormatter.string(from: date)
	}

	static func getCurrentDate() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000+00:00"
		return dateFormatter.string(from: Date())
	}
}
