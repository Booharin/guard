//
//  SocketStompService.swift
//  Guard
//
//  Created by Alexandr Bukharin on 20.12.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Foundation
import RxSwift
import MyTrackerSDK

protocol HasSocketStompService {
	var socketStompService: SocketStompServiceInterface { get set }
}

protocol SocketStompServiceInterface {
	var incomingMessageSubject: PublishSubject<Any> { get }
	func connectSocketStomp()
	func disconnect()
	func sendMessage(with text: String,
					 to: String,
					 receiptId: String?,
					 headers: [String: String]?)

	func sendData(with body: Data,
				  to: String,
				  receiptId: String?,
				  headers: [String: String]?)

	func subscribe(to topic: String)

	func unsubscribe(from topic: String)
}

final class SocketStompService: SocketStompServiceInterface, HasDependencies {
	private var socketStomp: SwiftStomp
	private let environment: Environment
	typealias Dependencies =
		HasNotificationService &
		HasLocalStorageService
	lazy var di: Dependencies = DI.dependencies
	var incomingMessageSubject = PublishSubject<Any>()
	private var isPingEnabled = false

	init(environment: Environment) {
		self.environment = environment

		socketStomp = SwiftStomp(host: environment.socketUrl)
		socketStomp.enableLogging = true
		socketStomp.delegate = self
		socketStomp.autoReconnect = true
	}

	func connectSocketStomp() {
		socketStomp.connect(autoReconnect: true)
		if isPingEnabled == false {
			checkSocketConnection()
			isPingEnabled = true
		}
		//checkForInternetConnection()
	}

	func disconnect() {
		guard let profile = di.localStorageService.getCurrenClientProfile() else { return }
		unsubscribe(from: "/topic/\(profile.id)")
		socketStomp.disconnect()
	}

	func sendMessage(with text: String,
					 to: String,
					 receiptId: String?,
					 headers: [String: String]?) {

		trackSendMessageFirstTime()

		socketStomp.send(body: text,
						 to: to,
						 receiptId: receiptId,
						 headers: headers)
	}

	func sendData(with body: Data,
				  to: String,
				  receiptId: String?,
				  headers: [String: String]?) {

		socketStomp.send(body: body,
						 to: to,
						 receiptId: receiptId,
						 headers: headers)
	}

	func subscribe(to topic: String) {
		socketStomp.subscribe(to: topic)
	}

	func unsubscribe(from topic: String) {
		socketStomp.unsubscribe(from: topic)
	}

	private func checkForInternetConnection() {
		Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { [weak self] (timer) in
			if NetworkConnectivity.isConnectedToInternet {
//				#if DEBUG
//				print("Internet connected")
//				#endif
			} else {
//				#if DEBUG
//				print("Internet not connected")
//				#endif
				self?.socketStomp.connect(autoReconnect: true)
			}
		})
	}

	private func checkSocketConnection() {
		Timer.scheduledTimer(withTimeInterval: 40, repeats: true, block: { _ in
			print(self.socketStomp.ping())
		})
	}
}

extension SocketStompService: SwiftStompDelegate {
	func onConnect(swiftStomp: SwiftStomp, connectType: StompConnectType) {
		if connectType == .toSocketEndpoint{
			print("Connected to socket")
		} else if connectType == .toStomp {
			print("Connected to stomp")
			//** Subscribe to topics or queues just after connect to the stomp!
			guard let profile = di.localStorageService.getCurrenClientProfile() else { return }
			swiftStomp.subscribe(to: "/topic/\(profile.id)")
		}
	}

	func onDisconnect(swiftStomp: SwiftStomp,
					  disconnectType: StompDisconnectType) {
		if disconnectType == .fromSocket {
			print("Socket disconnected. Disconnect completed")
		} else if disconnectType == .fromStomp {
			print("Client disconnected from stomp but socket is still connected!")
		}
	}

	func onMessageReceived(swiftStomp: SwiftStomp,
						   message: Any?,
						   messageId: String,
						   destination: String,
						   headers: [String : String]) {
		if let message = message as? String {
			#if DEBUG
			print("Message with id `\(messageId)` received at destination `\(destination)`:\n\(message)")
			#endif
			incomingMessageSubject.onNext(())
			NotificationCenter.default.post(name: Notification.Name(Constants.NotificationKeys.updateMessages),
											object: nil)
		} else if let message = message as? Data {
			#if DEBUG
			print("Data message with id `\(messageId)` and binary length `\(message.count)` received at destination `\(destination)`")
			#endif
			incomingMessageSubject.onNext(())
			NotificationCenter.default.post(name: Notification.Name(Constants.NotificationKeys.updateMessages),
											object: nil)
		}
	}

	func onReceipt(swiftStomp: SwiftStomp,
				   receiptId: String) {
		print("Receipt with id `\(receiptId)` received")
	}

	func onError(swiftStomp: SwiftStomp,
				 briefDescription: String,
				 fullDescription: String?,
				 receiptId: String?,
				 type: StompErrorType) {
		if type == .fromSocket {
			print("Socket error occurred! [\(briefDescription)]")
		} else if type == .fromStomp {
			print("Stomp error occurred! [\(briefDescription)] : \(String(describing: fullDescription))")
		} else {
			print("Unknown error occured!")
		}
	}

	func onSocketEvent(eventName: String, description: String) {
		print("Socket event occured: \(eventName) => \(description)")
	}

	private func convertStringToDictionary(text: String) -> [String: Any]? {
		if let data = text.data(using: .utf8) {
			do {
				return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
			} catch {
				print(error.localizedDescription)
			}
		}
		return nil
	}

	private func convertDataToDictionary(data: Data) -> [String: Any]? {
		do {
			return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
		} catch {
			return nil
		}
	}

	private func trackSendMessageFirstTime() {
		let id = UserDefaults.standard.integer(forKey: Constants.UserDefaultsKeys.userId)

		if id == 0 || id != di.localStorageService.getCurrenClientProfile()?.id {
			let parameters = [
				"userId": String(id),
				"isLayer": di.localStorageService.getCurrenClientProfile()?.userRole == .lawyer ? "YES" : "NO",
			]
			MRMyTracker.trackEvent(withName: Constants.MyTracker.Events.userSentMessageFirstTime,
								   eventParams: parameters)

			UserDefaults.standard.setValue(di.localStorageService.getCurrenClientProfile()?.id,
										   forKey: Constants.UserDefaultsKeys.userId)
		}
	}
}
