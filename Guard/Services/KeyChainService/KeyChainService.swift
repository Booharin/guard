//
//  KeyChainService.swift
//  Guard
//
//  Created by Alexandr Bukharin on 18.11.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import KeychainSwift

protocol HasKeyChainService {
	var keyChainService: KeyChainServiceInterface { get set }
}
/// Service for handle keychain data interface
protocol KeyChainServiceInterface {

	/// Method for saving keychain data
	func save(_ value: String, for key: String)

	/// Method for geting keychain data
	func getValue(for key: String) -> String?
}
/// Service for handle keychain data
final class KeyChainService: KeyChainServiceInterface {
	private let keychain = KeychainSwift()

	func save(_ value: String, for key: String) {
		keychain.set(value, forKey: key)
	}

	func getValue(for key: String) -> String? {
		keychain.get(key)
	}
}
