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
	HasLocalStorageService {
	
    var locationService: LocationServiceInterface
	var localStorageService: LocalStorageServiceInterface
}

enum DI {
    static var dependencies: Dependencies!
}

class AppDIContainer {
    
    func createAppDependencies(launchOptions: [AnyHashable: Any]) -> Dependencies {
        
		let d = Dependencies(locationService: LocationSerice(),
							 localStorageService: LocalStorageService())
        return d
    }
}