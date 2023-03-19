//
//  AppDelegate.swift
//  BirthdayAlarm
//
//  Created by Alexandr Booharin on 10.03.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var coordinator: ApplicationCoordinator?
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        self.window = UIWindow()
        self.coordinator = ApplicationCoordinator()
        DI.dependencies = AppDIContainer().createAppDependencies(launchOptions: launchOptions ?? [:])
        
        window?.makeKeyAndVisible()
        coordinator?.start()

        return true
    }
}
