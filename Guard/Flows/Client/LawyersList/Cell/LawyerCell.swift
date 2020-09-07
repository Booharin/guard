//
//  LawyerCell.swift
//  Guard
//
//  Created by Alexandr Bukharin on 07.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

protocol LawyerCellProtocol {
	var containerView: UIView { get }
	var nameTitle: UILabel { get }
	var avatarImageView: UIImageView { get }
	var rateLabel: UILabel { get }
	var isFreeView: UIView { get }
}

class LawyerCell: UITableViewCell, LawyerCellProtocol {
	var containerView = UIView()
	var nameTitle = UILabel()
	var avatarImageView = UIImageView()
	var rateLabel = UILabel()
	var isFreeView = UIView()
	
	var viewModel: LawyerCellViewModel!
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		backgroundColor = .clear
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
		// avatar
		containerView.addSubview(avatarImageView)
		avatarImageView.snp.makeConstraints {
			$0.width.height.equalTo(42)
			$0.leading.equalToSuperview().offset(35)
			$0.top.equalToSuperview().offset(15)
			$0.bottom.equalToSuperview().offset(-15)
		}
		// name
		containerView.addSubview(nameTitle)
		nameTitle.snp.makeConstraints() {
			$0.leading.equalTo(avatarImageView.snp.trailing).offset(23)
			$0.trailing.equalToSuperview().offset(-100)
			$0.centerY.equalToSuperview()
		}
	}
}
