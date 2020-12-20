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
	HasCommonDataNetworkService,
	HasSocketStompService,
	HasKeyChainService,
	HasNotificationService {
	
	var locationService: LocationServiceInterface
	var localStorageService: LocalStorageServiceInterface
	var alertService: AlertServiceInterface
	var authService: AuthServiceInterface
	var registrationService: RegistrationServiceInterface
	var lawyersNetworkService: LawyersNetworkServiceInterface
	var appealsNetworkService: AppealsNetworkServiceInterface
	var commonDataNetworkService: CommonDataNetworkServiceInterface
	var socketStompService: SocketStompServiceInterface
	var keyChainService: KeyChainServiceInterface
	var notificationService: NotificationServiceInterface
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
							 commonDataNetworkService: CommonDataNetworkService(),
							 socketStompService: SocketStompService(environment: EnvironmentImp()),
							 keyChainService: KeyChainService(),
							 notificationService: NotificationService())
		return d
	}
}
