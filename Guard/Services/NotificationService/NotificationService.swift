//
//  NotificationService.swift
//  Guard
//
//  Created by Alexandr Bukharin on 20.12.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UserNotifications
import UIKit

protocol HasNotificationService {
	var notificationService: NotificationServiceInterface { get set }
}

protocol NotificationServiceInterface {
	func registerForRemoteNotification(with application: UIApplication)
	func showLocalNotification(with title: String, message: String)
	func saveDeviceToken(_ token: Data)
	func checkForNotReadMessages()
}

final class NotificationService:
	NSObject,
	NotificationServiceInterface,
	HasDependencies {

	private let notificationCenter = UNUserNotificationCenter.current()

	typealias Dependencies = HasKeyChainService
	lazy var di: Dependencies = DI.dependencies

	override init() {
		super.init()

		notificationCenter.delegate = self
	}

	func registerForRemoteNotification(with application: UIApplication) {
		notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
			if success {
				DispatchQueue.main.async {
					application.registerForRemoteNotifications()
				}
			} else if let error = error {
				#if DEBUG
				print("Registration for remote notification failed: \(error.localizedDescription)")
				#endif
			}
		}
	}

	func showLocalNotification(with title: String, message: String) {

		let content = UNMutableNotificationContent()
		content.title = title
		content.body = message
		content.sound = UNNotificationSound.default
		content.badge = 0

		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
		let identifier = "Local Notification"
		let request = UNNotificationRequest(identifier: identifier,
											content: content,
											trigger: trigger)

		notificationCenter.add(request) { (error) in
			if let error = error {
				print("Error \(error.localizedDescription)")
			}
		}
	}

	func saveDeviceToken(_ token: Data) {
		let deviceTokenString = token.reduce("", { $0 + String(format: "%02X", $1) })
		#if DEBUG
		print("deviceToken: ", deviceTokenString)
		#endif
		di.keyChainService.save(deviceTokenString, for: Constants.KeyChainKeys.deviceToken)
		UIPasteboard.general.string = deviceTokenString
	}

	func checkForNotReadMessages() {
		NotificationCenter.default.post(name: Notification.Name(Constants.NotificationKeys.updateMessages),
										object: nil)
	}
}

extension NotificationService: UNUserNotificationCenterDelegate {
	func userNotificationCenter(_ center: UNUserNotificationCenter,
								willPresent notification: UNNotification,
								withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

		let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first

		if let navController = keyWindow?.rootViewController as? UINavigationController,
		   let tabbarViewController = navController.viewControllers.last as? TabBarController,
		   let vcCount = tabbarViewController.viewControllers?.count,
		   let chatNavController = tabbarViewController.viewControllers?[vcCount - 2] as? UINavigationController,
		   let _ = chatNavController.viewControllers.last as? ChatViewController {
			return
		} else {
			completionHandler([.alert, .badge, .sound])
		}
	}
	
	func userNotificationCenter(_ center: UNUserNotificationCenter,
								didReceive response: UNNotificationResponse,
								withCompletionHandler completionHandler: @escaping () -> Void) {

		let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first

		if let navController = keyWindow?.rootViewController as? UINavigationController,
		   let tabbarViewController = navController.viewControllers.last as? TabBarController,
		   let viewControllersCount = tabbarViewController.viewControllers?.count,
		   tabbarViewController.selectedIndex != viewControllersCount - 2 {
			tabbarViewController.selectedIndex = viewControllersCount - 2
		}

		completionHandler()
	}
}
