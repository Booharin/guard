//
//  Dependencies.swift
//  Guard
//
//  Created by Alexandr Bukharin on 16.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Foundation

protocol HasDependencies: class {
	associatedtype Dependencies
	
	var di: Dependencies { get set }
}

struct Dependencies:
	HasLocationService,
	HasLocalStorageService,
	HasAlertService,
	HasAuthService,
	HasRegistrationService,
	HasLawyersNetworkService,
	HasAppealsNetworkService,
	HasSocketService,
	HasKeyChainService {
	
	var locationService: LocationServiceInterface
	var localStorageService: LocalStorageServiceInterface
	var alertService: AlertServiceInterface
	var authService: AuthServiceInterface
	var registrationService: RegistrationServiceInterface
	var lawyersNetworkService: LawyersNetworkServiceInterface
	var appealsNetworkService: AppealsNetworkServiceInterface
	var socketService: SocketServiceInterface
	var keyChainService: KeyChainServiceInterface
}

enum DI {
	static var dependencies: Dependencies!
}

class AppDIContainer {
	
	func createAppDependencies(launchOptions: [AnyHashable: Any]) -> Dependencies {

		let d = Dependencies(locationService: LocationSerice(),
							 localStorageService: LocalStorageService(),
							 alertService: AlertService(),
							 authService: AuthService(),
							 registrationService: RegistrationService(),
							 lawyersNetworkService: LawyersNetworkService(),
							 appealsNetworkService: AppealsNetworkService(),
							 socketService: SocketService(environment: EnvironmentImp()),
							 keyChainService: KeyChainService())
		return d
	}
}
