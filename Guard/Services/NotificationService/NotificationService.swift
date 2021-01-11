//
//  NotificationService.swift
//  Guard
//
//  Created by Alexandr Bukharin on 20.12.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UserNotifications

protocol HasNotificationService {
	var notificationService: NotificationServiceInterface { get set }
}

protocol NotificationServiceInterface {
	func showLocalNotification(with title: String, message: String)
}

final class NotificationService: NSObject, NotificationServiceInterface {
	private let notificationCenter = UNUserNotificationCenter.current()

	override init() {
		super.init()

		notificationCenter.delegate = self
		notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
			if !success {
				print("User has declined notifications")
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
}

extension NotificationService: UNUserNotificationCenterDelegate {
	func userNotificationCenter(_ center: UNUserNotificationCenter,
								willPresent notification: UNNotification,
								withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

		completionHandler([.alert, .badge, .sound])
	}
}
