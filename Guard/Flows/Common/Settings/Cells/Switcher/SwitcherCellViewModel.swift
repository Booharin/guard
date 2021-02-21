//
//  SwitcherCellViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 25.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

final class SwitcherCellViewModel:
	ViewModel,
	HasDependencies {

	var view: SwitcherCellProtocol!
	private let title: String
	private let isOn: Bool
	private let isSeparatorHidden: Bool
	private let showLoaderSubject: PublishSubject<Bool>

	typealias Dependencies =
		HasClientNetworkService &
		HasLocalStorageService
	lazy var di: Dependencies = DI.dependencies

	var clientProfile: UserProfile? {
		di.localStorageService.getCurrenClientProfile()
	}
	var settings: SettingsModel? {
		di.localStorageService.getSettings(for: clientProfile?.id ?? 0)
	}
	private var disposeBag = DisposeBag()

	init(title: String,
		 isOn: Bool,
		 isSeparatorHidden: Bool,
		 showLoaderSubject: PublishSubject<Bool>) {
		self.title = title
		self.isOn = isOn
		self.isSeparatorHidden = isSeparatorHidden
		self.showLoaderSubject = showLoaderSubject
	}

	func viewDidSet() {
		view.titleLabel.text = title
		view.titleLabel.font = SFUIDisplay.regular.of(size: 16)
		view.titleLabel.textColor = Colors.mainTextColor
		
		view.switcher.setOn(isOn, animated: false)
		view.switcher.isUserInteractionEnabled = true
		view.switcher
			.rx
			.isOn.changed
			.do(onNext: { [unowned self] _ in
				self.view.switcher.isUserInteractionEnabled = false
				//self.showLoaderSubject.onNext(true)
			})
			.distinctUntilChanged()
			.asObservable()
			.flatMap ({ isOn -> Observable<SettingsModel> in
				var settings = SettingsModel(id: self.clientProfile?.id ?? 0,
											 isPhoneVisible: self.settings?.isPhoneVisible ?? true,
											 isEmailVisible: self.settings?.isEmailVisible ?? true,
											 isChatEnabled: self.settings?.isChatEnabled ?? true)
				switch self.view.titleLabel.text {
				case "settings.visibility.phone".localized:
					settings.isPhoneVisible = isOn
				case "settings.visibility.mail".localized:
					settings.isEmailVisible = isOn
				case "settings.visibility.chat".localized:
					settings.isChatEnabled = isOn
				default:
					break
				}
				return .just(settings)
			})
			.asObservable()
			.flatMap { [unowned self] settings in
				self.di.clientNetworkService
					.saveSettings(settingsModel: settings)
			}
			.subscribe(onNext:{ [weak self] result in
				self?.view.switcher.isUserInteractionEnabled = true
				//self?.showLoaderSubject.onNext(false)

				switch result {
					case .success:
						print("Switched")
					case .failure(let error):
						//TODO: - обработать ошибку
						print(error.localizedDescription)
						self?.view.switcher.setOn(!(self?.view.switcher.isOn ?? false), animated: true)
				}
			}).disposed(by: disposeBag)

		view.separatorView.backgroundColor = Colors.separatorColor
		view.separatorView.isHidden = isSeparatorHidden
	}

	func removeBindings() {}
}
