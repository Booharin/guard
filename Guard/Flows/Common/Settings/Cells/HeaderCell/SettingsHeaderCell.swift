//
//  SettingsHeaderCell.swift
//  Guard
//
//  Created by Alexandr Bukharin on 28.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

protocol SettingsHeaderCellProtocol {
	var containerView: UIView { get }
	var titleLabel: UILabel { get }
}

final class SettingsHeaderCell: UITableViewCell, SettingsHeaderCellProtocol {
	var containerView = UIView()
	var titleLabel = UILabel()
	var viewModel: SettingsHeaderCellViewModel!

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		backgroundColor = .clear
		selectionStyle = .none
		addViews()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func addViews() {
		addSubview(containerView)
		containerView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
		// title
		containerView.addSubview(titleLabel)
		titleLabel.snp.makeConstraints {
			$0.leading.equalToSuperview().offset(35)
			$0.top.equalToSuperview().offset(25)
			$0.bottom.equalToSuperview().offset(-25)
			$0.height.equalTo(20)
		}
	}
}
