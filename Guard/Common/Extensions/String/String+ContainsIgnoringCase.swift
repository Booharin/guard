//
//  String+ContainsIgnoringCase.swift
//  Guard
//
//  Created by Alexandr Bukharin on 09.04.2021.
//  Copyright © 2021 ds. All rights reserved.
//

extension String {
	func containsIgnoringCase(_ find: String) -> Bool{
		return self.range(of: find, options: .caseInsensitive) != nil
	}
}
