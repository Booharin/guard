//
//  ReviewCell.swift
//  Guard
//
//  Created by Alexandr Bukharin on 27.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit

protocol ReviewCellProtocol {
	var containerView: UIView { get }
	var avatarImageView: UIImageView { get }
	var nameTitleLabel: UILabel { get }
	var descriptionLabel: UILabel { get }
	var dateLabel: UILabel { get }
	var rateLabel: UILabel { get }
}

class ReviewCell: UITableViewCell, ReviewCellProtocol {
	var containerView = UIView()
	var avatarImageView = UIImageView()
	var nameTitleLabel = UILabel()
	var descriptionLabel = UILabel()
	var dateLabel = UILabel()
	var rateLabel = UILabel()
	var viewModel: ReviewCellViewModel!

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
		// appeal ImageView
		containerView.addSubview(avatarImageView)
		avatarImageView.snp.makeConstraints {
			$0.width.height.equalTo(42)
			$0.leading.equalToSuperview().offset(35)
			$0.top.equalToSuperview().offset(15)
			$0.bottom.equalToSuperview().offset(-15)
		}
		// description Label
		containerView.addSubview(descriptionLabel)
		descriptionLabel.snp.makeConstraints {
			$0.leading.equalTo(avatarImageView.snp.trailing).offset(23)
			$0.centerY.equalToSuperview()
			$0.trailing.equalToSuperview().offset(-100)
			$0.height.equalTo(15)
		}
		// name title Label
		containerView.addSubview(nameTitleLabel)
		nameTitleLabel.snp.makeConstraints {
			$0.leading.equalTo(avatarImageView.snp.trailing).offset(23)
			$0.bottom.equalTo(descriptionLabel.snp.top).offset(-1)
			$0.trailing.equalToSuperview().offset(-100)
			$0.height.equalTo(19)
		}
		// date label
		containerView.addSubview(dateLabel)
		dateLabel.snp.makeConstraints {
			$0.leading.equalTo(avatarImageView.snp.trailing).offset(23)
			$0.top.equalTo(descriptionLabel.snp.bottom).offset(1)
			$0.trailing.equalToSuperview().offset(-100)
			$0.height.equalTo(19)
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
