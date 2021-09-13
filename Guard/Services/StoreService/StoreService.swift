//
//  StoreService.swift
//  Guard
//
//  Created by Alexandr Bukharin on 12.09.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import StoreKit

protocol HasStoreService {
	var storeService: StoreServiceInterface { get set }
}

protocol StoreServiceInterface {
	func fetchProducts()
}

final class StoreService: NSObject, StoreManagerProtocol {
	private var productModels = [SKProduct]()
	private var isPamentCreated = false

	override init() {
		super.init()
		SKPaymentQueue.default().add(self)
		fetchProducts()
		DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
			self.createPayment()
		})
	}

	func fetchProducts() {
		let request = SKProductsRequest(
			productIdentifiers: Set(
				[
					"month_subscription"
				]
			)
		)
		request.delegate = self
		request.start()
	}

	func createPayment() {
		guard let productModel = productModels.first else { return }
		let payment = SKPayment(product: productModel)
		isPamentCreated = true
		SKPaymentQueue.default().add(payment)
	}
}

extension StoreService: SKProductsRequestDelegate {
	func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
		print(response.products)
		productModels = response.products
	}
}

extension StoreService: SKPaymentTransactionObserver {
	func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		transactions.forEach {
			switch $0.transactionState {
			case .purchasing:
				print("purchasing")
			case .purchased:
				print("purchased")
				SKPaymentQueue.default().finishTransaction($0)
				if isPamentCreated {
					sendReceipt()
					isPamentCreated = false
				}
			case .failed:
				print("failed")
				SKPaymentQueue.default().finishTransaction($0)
			case .restored:
				print("restored")
				SKPaymentQueue.default().finishTransaction($0)
				if isPamentCreated {
					sendReceipt()
					isPamentCreated = false
				}
			case .deferred:
				print("deferred")
			default:
				break
			}
		}
	}

	private func sendReceipt() {
		if Bundle.main.appStoreReceiptURL == nil {
			print("appStoreReceiptURL is nil")
		}
		if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
		   FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
			do {
				let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
				let receiptString = receiptData.base64EncodedString(options: [])

				print("receiptString: \(receiptString)")

			}
			catch { print("Couldn't read receipt data with error: " + error.localizedDescription) }
		}
	}
}
