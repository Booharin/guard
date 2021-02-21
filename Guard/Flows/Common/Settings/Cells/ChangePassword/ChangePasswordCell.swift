//
//  ChangePasswordCell.swift
//  Guard
//
//  Created by Alexandr Bukharin on 18.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit

protocol ChangePasswordCellProtocol {
	var containerView: UIView { get }
	var titleLabel: UILabel { get }
	var iconImageView: UIImageView { get }
	var separatorView: UIView { get }
}

class ChangePasswordCell: UITableViewCell, ChangePasswordCellProtocol {

	var containerView = UIView()
	var titleLabel = UILabel()
	var iconImageView = UIImageView()
	var separatorView = UIView()
	var viewModel: ChangePasswordCellViewModel!

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
			$0.trailing.equalToSuperview().offset(-47)
			$0.width.equalTo(7)
			$0.height.equalTo(12)
			$0.centerY.equalToSuperview()
		}
		// separator
		containerView.addSubview(separatorView)
		separatorView.snp.makeConstraints {
			$0.height.equalTo(1)
			$0.leading.equalToSuperview().offset(36)
			$0.trailing.equalToSuperview().offset(-36)
			$0.bottom.equalToSuperview()
		}
	}
}
