//
//  SettingsDataSource.swift
//  Guard
//
//  Created by Alexandr Bukharin on 25.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxDataSources
import RxSwift

enum SettingsCellType {
	case headerItem(title: String)
	case notificationItem(title: String,
						  isOn: Bool,
						  isSeparatorHidden: Bool,
						  showLoaderSubject: PublishSubject<Bool>)
	case changePasswordItem(changePasswordSubject: PublishSubject<Any>)
	case logoutItem(logoutSubject: PublishSubject<Any>)
}

struct SettingsDataSource {
	typealias DataSource = RxTableViewSectionedReloadDataSource
	
	static func dataSource() -> DataSource<SectionModel<String, SettingsCellType>> {
		return .init(configureCell: { dataSource, tableView, indexPath, cellType -> UITableViewCell in
			switch cellType {
			case let .headerItem(title):
				let cell = SettingsHeaderCell()
				cell.viewModel = SettingsHeaderCellViewModel(title: title)
				cell.viewModel.assosiateView(cell)
				return cell
			case let .notificationItem(title,
									   isOn,
									   isSeparatorHidden,
									   showLoaderSubject):
				let cell = SwitcherCell()
				cell.viewModel = SwitcherCellViewModel(title: title,
													   isOn: isOn,
													   isSeparatorHidden: isSeparatorHidden,
													   showLoaderSubject: showLoaderSubject)
				cell.viewModel.assosiateView(cell)
				return cell
			case let .changePasswordItem(changePasswordSubject: changePasswordSubject):
				let cell = ChangePasswordCell()
				cell.viewModel = ChangePasswordCellViewModel(changePasswordSubject: changePasswordSubject)
				cell.viewModel.assosiateView(cell)
				return cell
			case let .logoutItem(logoutSubject):
				let cell = LogoutCell()
				cell.viewModel = LogoutCellViewModel(logoutSubject: logoutSubject)
				cell.viewModel.assosiateView(cell)
				return cell
			}
		})
	}
}
