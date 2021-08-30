//
//  ChooseRouter.swift
//  Guard
//
//  Created by Alexandr Bukharin on 19.07.2021.
//  Copyright © 2021 ds. All rights reserved.
//

final class ChooseRouter {
	/// Pass to registration
	var toRegistration: ((UserRole) -> (Void))?
	/// Pass to main with client
	var toMainWithClient: (() -> (Void))?
}
