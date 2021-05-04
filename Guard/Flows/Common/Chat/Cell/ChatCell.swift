//
//  ChatCell.swift
//  Guard
//
//  Created by Alexandr Bukharin on 15.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

protocol ChatCellProtocol {
	var containerView: UIView { get }
	var bubbleView: UIView { get }
	var messageTextView: UITextView { get }
	var dateLabel: UILabel { get }
}

final class ChatCell:
	UITableViewCell,
	ChatCellProtocol,
	HasDependencies {

	typealias Dependencies = HasLocalStorageService
	lazy var di: Dependencies = DI.dependencies

	var containerView = UIView()
	var bubbleView = UIView()
	var messageTextView = UITextView()
	var dateLabel = UILabel()

	var viewModel: ChatCellViewModel! {
		didSet {
			switch viewModel.chatMessage.senderId {
			// outgoing
			case di.localStorageService.getCurrenClientProfile()?.id ?? 0:
				// bubble
				bubbleView.snp.makeConstraints {
					$0.trailing.equalToSuperview().offset(-35)
					$0.leading.greaterThanOrEqualToSuperview().offset(82)
				}
				// date
				dateLabel.snp.makeConstraints {
					$0.trailing.equalTo(bubbleView.snp.trailing).offset(-2)
				}
			// incoming
			default:
				// bubble
				bubbleView.snp.makeConstraints {
					$0.leading.equalToSuperview().offset(35)
					$0.trailing.lessThanOrEqualToSuperview().offset(-82)
				}
				// date
				dateLabel.snp.makeConstraints {
					$0.leading.equalTo(bubbleView.snp.leading).offset(2)
				}
			}
		}
	}
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		selectionStyle = .none
		setupViews()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupViews() {
		backgroundColor = .clear

		// container
		contentView.addSubview(containerView)
		containerView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}

		// bubble
		containerView.addSubview(bubbleView)
		bubbleView.snp.makeConstraints {
			$0.top.equalToSuperview().offset(18)
			//$0.bottom.equalToSuperview().offset(-29)
			//$0.width.lessThanOrEqualTo(258)
		}

		// message
		bubbleView.addSubview(messageTextView)
		messageTextView.snp.makeConstraints {
			$0.leading.equalToSuperview().offset(8)
			$0.trailing.equalToSuperview().offset(-8)
			$0.top.equalToSuperview()//.offset(8)
			$0.bottom.equalToSuperview()//.offset(-8)
		}

		// date
		containerView.addSubview(dateLabel)
		dateLabel.snp.makeConstraints {
			$0.top.equalTo(bubbleView.snp.bottom).offset(6)
			$0.bottom.equalToSuperview().offset(-5)
			$0.height.equalTo(12)
		}
	}
}
