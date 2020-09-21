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
    var avatarImageView: UIImageView { get }
	var nameTitle: UILabel { get }
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
		nameTitle.snp.makeConstraints {
			$0.leading.equalTo(avatarImageView.snp.trailing).offset(23)
			$0.trailing.equalToSuperview().offset(-100)
			$0.centerY.equalToSuperview()
		}
        // star image view
        let starImageView = UIImageView(image: #imageLiteral(resourceName: "star_icn"))
        containerView.addSubview(starImageView)
        starImageView.snp.makeConstraints {
            $0.width.height.equalTo(13)
            $0.trailing.equalToSuperview().offset(-65)
            $0.centerY.equalToSuperview()
        }
        // rate label
        containerView.addSubview(rateLabel)
        rateLabel.snp.makeConstraints {
            $0.leading.equalTo(starImageView.snp.trailing).offset(7)
            $0.height.equalTo(20)
            $0.centerY.equalToSuperview()
        }
	}
}
