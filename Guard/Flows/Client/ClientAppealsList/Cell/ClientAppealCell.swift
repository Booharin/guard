//
//  ClientAppealCell.swift
//  Guard
//
//  Created by Alexandr Bukharin on 09.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

protocol ClientAppealCellProtocol {
	var containerView: UIView { get }
	var appealImageView: UIImageView { get }
	var titleLabel: UILabel { get }
	var descriptionLabel: UILabel { get }
	var dateLabel: UILabel { get }
	var timeLabel: UILabel { get }
}

class ClientAppealCell: UITableViewCell, ClientAppealCellProtocol {
	var containerView = UIView()
	var appealImageView = UIImageView()
	var titleLabel = UILabel()
	var descriptionLabel = UILabel()
	var dateLabel = UILabel()
	var timeLabel = UILabel()
	
	var viewModel: ClientAppealCellViewModel!
	
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
		containerView.addSubview(appealImageView)
		appealImageView.snp.makeConstraints {
			$0.width.height.equalTo(52)
			$0.leading.equalToSuperview().offset(35)
			$0.top.equalToSuperview().offset(14)
			$0.bottom.equalToSuperview().offset(-14)
		}
		// title Label
		containerView.addSubview(titleLabel)
		titleLabel.snp.makeConstraints {
			$0.leading.equalTo(appealImageView.snp.trailing).offset(13)
			$0.top.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-93)
			$0.height.equalTo(19)
		}
		// description Label
		containerView.addSubview(descriptionLabel)
		descriptionLabel.snp.makeConstraints {
			$0.leading.equalTo(appealImageView.snp.trailing).offset(13)
			$0.top.equalTo(titleLabel.snp.bottom).offset(4)
			$0.trailing.equalToSuperview().offset(-93)
			$0.bottom.equalToSuperview().offset(-20)
		}
		// date label
		containerView.addSubview(dateLabel)
		dateLabel.snp.makeConstraints {
			$0.top.equalToSuperview().offset(28)
			$0.trailing.equalToSuperview().offset(-35)
		}
		// time label
		containerView.addSubview(timeLabel)
		timeLabel.snp.makeConstraints {
			$0.top.equalTo(dateLabel.snp.bottom).offset(8)
			$0.trailing.equalToSuperview().offset(-35)
		}
	}
}
