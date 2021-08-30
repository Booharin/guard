//
//  RegistrationCoordinator.swift
//  Guard
//
//  Created by Alexandr Bukharin on 11.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
import RxSwift

final class RegistrationCoordinator:
	BaseCoordinator,
	HasDependencies {

	typealias Dependencies =
		HasKeyChainService &
		HasLocalStorageService &
		HasLawyersNetworkService &
		HasKeyChainService
	lazy var di: Dependencies = DI.dependencies

	var userProfile: UserProfile?

	private var lawyerEditSubject = PublishSubject<UserProfile>()

	var rootController: NavigationController?
	var onFinishFlow: (() -> Void)?
	private let userRole: UserRole

	private var navController: NavigationController? {
		UIApplication.shared.windows.first?.rootViewController as? NavigationController
	}

	private var disposeBag = DisposeBag()

	init(userRole: UserRole) {
		self.userRole = userRole
	}

	override func start() {
		showRegistrationModule()
	}

	private func showRegistrationModule() {
		// to select issue
		let toSelectIssueSubject = PublishSubject<Any>()
		toSelectIssueSubject
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] _ in
				self?.toSelectIssue()
			})
			.disposed(by: disposeBag)
		// to auth
		let toAuthSubject = PublishSubject<Any>()
		toAuthSubject
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] _ in
				self?.toAuth()
			})
			.disposed(by: disposeBag)

		let registrationViewModel = RegistrationViewModel(toSelectIssueSubject: toSelectIssueSubject,
														  toAuthSubject: toAuthSubject,
														  userRole: self.userRole)
		let controller = RegistrationViewController(viewModel: registrationViewModel)
		
		guard let navVC = UIApplication.shared.windows.first?.rootViewController as? NavigationController else { return }
		navVC.pushViewController(controller, animated: true)
	}

	private func toMain(issueType: IssueType? = nil) {
		let coordinator = MainCoordinator(userRole: userRole,
										  issueType: issueType)
		coordinator.onFinishFlow = { [weak self, weak coordinator] in
			self?.removeDependency(coordinator)
			self?.start()
		}
		addDependency(coordinator)
		coordinator.start()
	}

	private func toAuth() {
		let coordinator = AuthCoordinator()
		coordinator.onFinishFlow = { [weak self, weak coordinator] in
			self?.removeDependency(coordinator)
		}
		addDependency(coordinator)
		coordinator.start()
	}

	private func toSelectIssue() {
		userProfile = di.localStorageService.getCurrenClientProfile()

		switch userProfile?.userRole {
		//MARK: - Lawyer
		case .lawyer:
			let filterIssuesSubject = PublishSubject<[Int]>()
			filterIssuesSubject
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: { subIssueCodes in

					// save subIssue types for new lawyer
					if var profile = self.userProfile,
					   profile.userRole == .lawyer {

						profile.subIssueCodes = subIssueCodes
						profile.email = ""
						profile.phoneNumber = ""
						self.di.localStorageService.saveProfile(profile)
						self.lawyerEditSubject.onNext(profile)
					}

					self.toMain()
					self.onFinishFlow?()
				})
				.disposed(by: disposeBag)

			lawyerEditSubject
				.asObservable()
				.flatMap { [unowned self] profile in
					self.di.lawyersNetworkService
						.editLawyer(profile: profile,
									email: self.di.keyChainService.getValue(for: Constants.KeyChainKeys.email) ?? "",
									phone: "")
				}
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: { _ in })
				.disposed(by: disposeBag)

			let controller = FilterScreenModuleFactory.createModule(filterTitle: "filter.issues.title".localized,
																	subIssuesCodes: [],
																	selectedIssuesSubject: filterIssuesSubject)
			navController?.present(controller, animated: true)

		//MARK: - Client
		case .client:
			toMain()
			onFinishFlow?()
		default:
			break
		}
	}
	
	deinit {
		print("\(String(describing: self)) deinited")
	}
}
