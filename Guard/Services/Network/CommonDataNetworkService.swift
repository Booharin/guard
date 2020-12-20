//
//  CommonDataNetworkService.swift
//  Guard
//
//  Created by Alexandr Bukharin on 13.12.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Alamofire
import RxSwift
import Foundation

protocol HasCommonDataNetworkService {
	var commonDataNetworkService: CommonDataNetworkServiceInterface { get set }
}

protocol CommonDataNetworkServiceInterface {
	func getCountriesAndCities() -> Observable<Result<[CountryModel], AFError>>
	func getIssueTypes(for locale: String) -> Observable<Result<[IssueType], AFError>>
}

final class CommonDataNetworkService: CommonDataNetworkServiceInterface {
	private let router: CommonDataNetworkRouter
	typealias Dependencies =
		HasKeyChainService
	lazy var di: Dependencies = DI.dependencies

	init() {
		router = CommonDataNetworkRouter(environment: EnvironmentImp())
	}

	func getCountriesAndCities() -> Observable<Result<[CountryModel], AFError>> {
		return Observable<Result>.create { (observer) -> Disposable in
			let requestReference = AF.request(
				self.router.getCountriesAndCities()
			)
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
						let countries = try JSONDecoder().decode([CountryModel].self, from: data)
						observer.onNext(.success(countries))
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

	func getIssueTypes(for locale: String) -> Observable<Result<[IssueType], AFError>> {
		return Observable<Result>.create { (observer) -> Disposable in
			let requestReference = AF.request(
				self.router.getIssueTypes(for: locale)
			)
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
						let issueTypes = try JSONDecoder().decode([IssueType].self, from: data)
						observer.onNext(.success(issueTypes))
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
