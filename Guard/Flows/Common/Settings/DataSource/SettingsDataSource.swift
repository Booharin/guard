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
	case notificationItem(title: String, isOn: Bool)
	case logoutItem(logoutSubject: PublishSubject<Any>)
}

enum SettingsTableViewSection {
	case VisibilitySection(items: [SettingsCellType])
	case LogoutSection(items: [SettingsCellType])
}

extension SettingsTableViewSection {
	typealias Item = SettingsCellType

	var header: String {
		switch self {
		case .VisibilitySection:
			return "settings.visibility.title".localized
		case .LogoutSection:
			return "settings.logout.title".localized
		}
	}
}

struct SettingsDataSource {
	typealias DataSource = RxTableViewSectionedReloadDataSource
	
	static func dataSource(logoutSubject: PublishSubject<Any>) -> DataSource<SectionModel<String, SettingsCellType>> {
		return .init(configureCell: { dataSource, tableView, indexPath, cellType -> UITableViewCell in
			switch cellType {
			case let .notificationItem(title, isOn):
				let cell = SwitcherCell()
				cell.viewModel = SwitcherCellViewModel(title: title, isOn: isOn)
				cell.viewModel.assosiateView(cell)
				return cell
			case let .logoutItem(logoutSubject):
				let cell = LogoutCell()
				cell.viewModel = LogoutCellViewModel(logoutSubject: logoutSubject)
				cell.viewModel.assosiateView(cell)
				return cell
			}
		}, titleForHeaderInSection: { dataSource, index in
			return dataSource.sectionModels[index].model
		})
	}
}
