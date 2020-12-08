//
//  SocketService.swift
//  Guard
//
//  Created by Alexandr Bukharin on 17.11.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Starscream

protocol HasSocketService {
	var socketService: SocketServiceInterface { get set }
}

protocol SocketServiceInterface {
	var isConnected: Bool { get }
	func connectSockets()
	func disconnectSockets()
	func reconnectSockets()
	func sendMessage(_ text: String)
	func sendData(_ data: Data)
}

final class SocketService: SocketServiceInterface {
	var socket: WebSocket?
	var isConnecting = false
	var isConnected = false
	private let environment: Environment
	init(environment: Environment) {
		self.environment = environment
	}
	
	func connectSockets() {
		var request = URLRequest(url: environment.socketUrl)
		request.timeoutInterval = 5
		socket = WebSocket(request: request)
		socket?.delegate = self
		socket?.connect()
	}

	func disconnectSockets() {
		if isConnected {
			socket?.disconnect()
		}
	}
	func reconnectSockets() {
		if !isConnected {
			socket?.connect()
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
			if !self.isConnected {
				print("[SOCKET MANAGER] Reconnecting sockets")
				self.reconnectSockets()
			}
		}
	}

	func sendMessage(_ text: String) {
		socket?.write(string: text)
	}

	func sendData(_ data: Data) {
		socket?.write(data: data)
	}
}

extension SocketService: WebSocketDelegate {
	func didReceive(event: WebSocketEvent, client: WebSocket) {
		switch event {
		case .connected(let headers):
			isConnected = true
			print("websocket is connected: \(headers)")
		case .disconnected(let reason, let code):
			isConnected = false
			print("websocket is disconnected: \(reason) with code: \(code)")
		case .text(let string):
			print("Received text: \(string)")
		case .binary(let data):
			print("Received data: \(data.count)")
		case .ping(_):
			break
		case .pong(_):
			break
		case .viabilityChanged(_):
			break
		case .reconnectSuggested(_):
			break
		case .cancelled:
			isConnected = false
		case .error(let error):
			isConnected = false
			print("error: \(error)")
		//handleError(error)
		}
	}
}
