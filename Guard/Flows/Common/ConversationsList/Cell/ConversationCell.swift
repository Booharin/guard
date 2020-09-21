//
//  ConversationCell.swift
//  Guard
//
//  Created by Alexandr Bukharin on 15.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

protocol ConversationCellProtocol {
	var containerView: UIView { get }
	var avatarImageView: UIImageView { get }
	var nameTitleLabel: UILabel { get }
    var lastMessageLabel: UILabel { get }
    var dateLabel: UILabel { get }
    var timeLabel: UILabel { get }
}

final class ConversationCell: UITableViewCell, ConversationCellProtocol {
	var containerView = UIView()
	var avatarImageView = UIImageView()
	var nameTitleLabel = UILabel()
	var lastMessageLabel = UILabel()
	var dateLabel = UILabel()
	var timeLabel = UILabel()
	var viewModel: ConversationCellViewModel!
	
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
		// appeal ImageView
		containerView.addSubview(avatarImageView)
		avatarImageView.snp.makeConstraints {
			$0.width.height.equalTo(42)
			$0.leading.equalToSuperview().offset(35)
			$0.top.equalToSuperview().offset(15)
			$0.bottom.equalToSuperview().offset(-15)
		}
		// name title Label
		containerView.addSubview(nameTitleLabel)
		nameTitleLabel.snp.makeConstraints {
			$0.leading.equalTo(avatarImageView.snp.trailing).offset(23)
			$0.top.equalToSuperview().offset(17)
			$0.trailing.equalToSuperview().offset(-100)
			$0.height.equalTo(19)
		}
		// description Label
		containerView.addSubview(lastMessageLabel)
		lastMessageLabel.snp.makeConstraints {
			$0.leading.equalTo(avatarImageView.snp.trailing).offset(23)
			$0.top.equalTo(nameTitleLabel.snp.bottom).offset(4)
			$0.trailing.equalToSuperview().offset(-100)
			$0.bottom.equalToSuperview().offset(-18)
		}
		// date label
		containerView.addSubview(dateLabel)
		dateLabel.snp.makeConstraints {
			$0.top.equalToSuperview().offset(20)
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
