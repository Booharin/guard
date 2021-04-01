//
//  String+PhoneNumber.swift
//  Guard
//
//  Created by Alexandr Bukharin on 28.02.2021.
//  Copyright © 2021 ds. All rights reserved.
//

extension String {
	var phoneNumberFormat: String {
		let numbers = self.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
		let mask = "+X (XXX) XXX-XXXX"
		var result = ""
		var index = numbers.startIndex // numbers iterator

		// iterate over the mask characters until the iterator of numbers ends
		for ch in mask where index < numbers.endIndex {
			if ch == "X" {
				// mask requires a number in this place, so take the next one
				result.append(numbers[index])

				// move numbers iterator to the next index
				index = numbers.index(after: index)

			} else {
				result.append(ch) // just append a mask character
			}
		}
		return result
	}
//	static func format(with mask: String, phone: String) -> String {
//		let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
//		var result = ""
//		var index = numbers.startIndex // numbers iterator
//
//		// iterate over the mask characters until the iterator of numbers ends
//		for ch in mask where index < numbers.endIndex {
//			if ch == "X" {
//				// mask requires a number in this place, so take the next one
//				result.append(numbers[index])
//
//				// move numbers iterator to the next index
//				index = numbers.index(after: index)
//
//			} else {
//				result.append(ch) // just append a mask character
//			}
//		}
//		return result
//	}
}
