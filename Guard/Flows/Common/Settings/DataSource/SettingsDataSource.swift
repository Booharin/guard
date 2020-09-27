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
	case notificationItem(title: String, isOn: Bool, isSeparatorHidden: Bool)
	case logoutItem(logoutSubject: PublishSubject<Any>)
}

enum SettingsTableViewSection {
	case VisibilitySection(items: [SettingsCellType])
	case LogoutSection(items: [SettingsCellType])
}

extension SettingsTableViewSection: SectionModelType {
	typealias Item = SettingsCellType

	var header: String {
		switch self {
		case .VisibilitySection:
			return "settings.visibility.title".localized
		case .LogoutSection:
			return "settings.logout.title".localized
		}
	}

	var items: [SettingsCellType] {
		switch self {
		case .VisibilitySection(items: let items):
			return items
		case .LogoutSection(items: let items):
			return items
		}
	}

	init(original: Self, items: [Self.Item]) {
		self = original
	}
}

struct SettingsDataSource {
	typealias DataSource = RxTableViewSectionedReloadDataSource
	
	static func dataSource() -> DataSource<SettingsTableViewSection> {
		return .init(configureCell: { dataSource, tableView, indexPath, cellType -> UITableViewCell in
			switch cellType {
			case let .notificationItem(title, isOn, isSeparatorHidden):
				let cell = SwitcherCell()
				cell.viewModel = SwitcherCellViewModel(title: title,
													   isOn: isOn,
													   isSeparatorHidden: isSeparatorHidden)
				cell.viewModel.assosiateView(cell)
				return cell
			case let .logoutItem(logoutSubject):
				let cell = LogoutCell()
				cell.viewModel = LogoutCellViewModel(logoutSubject: logoutSubject)
				cell.viewModel.assosiateView(cell)
				return cell
			}
		}, titleForHeaderInSection: { dataSource, index in
			return dataSource.sectionModels[index].header
		})
	}
}
