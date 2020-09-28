//
//  SwitcherCell.swift
//  Guard
//
//  Created by Alexandr Bukharin on 25.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

protocol SwitcherCellProtocol {
	var containerView: UIView { get }
	var titleLabel: UILabel { get }
	var switcher: UISwitch { get }
	var separatorView: UIView { get }
}

class SwitcherCell: UITableViewCell, SwitcherCellProtocol {
	var containerView = UIView()
	var titleLabel = UILabel()
	var switcher = UISwitch()
	var separatorView = UIView()
	var viewModel: SwitcherCellViewModel!

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
		// switch
		containerView.addSubview(switcher)
		switcher.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.width.equalTo(50)
			$0.height.equalTo(29)
			$0.trailing.equalToSuperview().offset(-35)
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
