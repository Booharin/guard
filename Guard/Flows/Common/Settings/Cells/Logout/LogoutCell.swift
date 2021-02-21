//
//  LogoutCell.swift
//  Guard
//
//  Created by Alexandr Bukharin on 25.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

protocol LogoutCellProtocol {
	var containerView: UIView { get }
	var titleLabel: UILabel { get }
	var iconImageView: UIImageView { get }
}

class LogoutCell: UITableViewCell, LogoutCellProtocol {

	var containerView = UIView()
	var titleLabel = UILabel()
	var iconImageView = UIImageView()
	var viewModel: LogoutCellViewModel!

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
		contentView.addSubview(containerView)
		containerView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
		// title
		containerView.addSubview(titleLabel)
		titleLabel.snp.makeConstraints {
			$0.leading.equalToSuperview().offset(35)
			$0.top.equalToSuperview().offset(21)
			$0.bottom.equalToSuperview().offset(-21)
			$0.height.equalTo(20)
		}
		// image
		containerView.addSubview(iconImageView)
		iconImageView.snp.makeConstraints {
			$0.trailing.equalToSuperview().offset(-36)
			$0.width.height.equalTo(24)
			$0.centerY.equalToSuperview()
		}
	}
}
