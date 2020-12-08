//
//  LawyersNetworkService.swift
//  Guard
//
//  Created by Alexandr Bukharin on 08.12.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Alamofire
import RxSwift
import Foundation

protocol HasLawyersNetworkService {
	var lawyersNetworkService: LawyersNetworkServiceInterface { get set }
}

protocol LawyersNetworkServiceInterface {
	func getAllLawyers(from city: String) -> Observable<Result<[UserProfile], AFError>>
}

final class LawyersNetworkService: LawyersNetworkServiceInterface {
	private let router: LawyersNetworkRouter

	init() {
		router = LawyersNetworkRouter(environment: EnvironmentImp())
	}

	func getAllLawyers(from city: String) -> Observable<Result<[UserProfile], AFError>> {
		return Observable<Result>.create { (observer) -> Disposable in
			let requestReference = AF.request(self.router.getAllLawyers(from: city))
				.responseJSON { response in
					#if DEBUG
					print(response)
					#endif
					switch response.result {
					case .success:
						guard let data = response.data else {
							observer.onNext(.failure(AFError.createURLRequestFailed(error: NetworkError.common)))
							return
						}
						do {
							let lawyers = try JSONDecoder().decode([UserProfile].self, from: data)
							observer.onNext(.success(lawyers))
							observer.onCompleted()
						} catch {
							#if DEBUG
							print(error)
							#endif
							observer.onNext(.failure(AFError.createURLRequestFailed(error: NetworkError.common)))
						}
					case .failure:
						observer.onNext(.failure(AFError.createURLRequestFailed(error: response.error ?? NetworkError.common)))
					}
			}
			return Disposables.create(with: {
				requestReference.cancel()
			})
		}
	}
}
