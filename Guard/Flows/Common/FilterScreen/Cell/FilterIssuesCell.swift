//
//  FilterIssuesCell.swift
//  Guard
//
//  Created by Alexandr Bukharin on 03.04.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit

protocol FilterIssuesCellProtocol {
	var cellContentView: UIView { get }
	var containerView: UIView { get }

	var issueTitleView: UIView { get }
	var issueImageView: UIImageView { get }
	var titleLabel: UILabel { get }
	var descriptionLabel: UILabel { get }
	var chevronImageView: UIImageView { get }
	var issuesCountLabel: UILabel { get }

	var subIssuesStackView: UIStackView { get }
}

final class FilterIssuesCell: UITableViewCell, FilterIssuesCellProtocol {
	var cellContentView: UIView {
		self.contentView
	}
	var containerView = UIView()

	var issueTitleView = UIView()
	var issueImageView = UIImageView()
	var titleLabel = UILabel()
	var descriptionLabel = UILabel()
	var chevronImageView = UIImageView()
	var issuesCountLabel = UILabel()

	var subIssuesStackView = UIStackView()

	var viewModel: FilterIssuesCellViewModel?

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
		containerView.addSubview(subIssuesStackView)

		// issue title view
		containerView.addSubview(issueTitleView)
		issueTitleView.snp.makeConstraints {
			$0.leading.equalToSuperview()
			$0.trailing.equalToSuperview()
			$0.top.equalToSuperview()
			$0.bottom.equalTo(subIssuesStackView.snp.top)
		}

		// issue image
		issueTitleView.addSubview(issueImageView)
		issueImageView.snp.makeConstraints {
			$0.width.height.equalTo(30)
			$0.leading.equalToSuperview().offset(30)
			$0.top.equalToSuperview().offset(15)
			$0.bottom.lessThanOrEqualTo(-15)
		}

		// title label
		issueTitleView.addSubview(titleLabel)
		titleLabel.snp.makeConstraints {
			$0.leading.equalToSuperview().offset(74)
			$0.trailing.equalToSuperview().inset(58)
			$0.top.equalToSuperview().offset(10)
			//$0.bottom.equalToSuperview().offset(-8)
		}
		// description label
		issueTitleView.addSubview(descriptionLabel)
		descriptionLabel.snp.makeConstraints {
			$0.leading.equalToSuperview().offset(74)
			$0.trailing.equalToSuperview().inset(58)
			$0.top.equalTo(titleLabel.snp.bottom).offset(9)
			$0.bottom.equalToSuperview().offset(-8)
		}

		// issues count label
		issueTitleView.addSubview(issuesCountLabel)
		issuesCountLabel.snp.makeConstraints {
			$0.centerX.equalTo(issueImageView.snp.centerX).offset(11)
			$0.centerY.equalTo(issueImageView.snp.centerY).offset(-13)
			$0.width.height.equalTo(14)
		}

		// subIssues stack view
		subIssuesStackView.snp.makeConstraints {
			$0.top.equalTo(issueTitleView.snp.bottom)
			$0.leading.trailing.equalToSuperview()
			$0.bottom.equalToSuperview().offset(-11)
		}

		// chevron image
		issueTitleView.addSubview(chevronImageView)
		chevronImageView.snp.makeConstraints {
			$0.width.equalTo(12)
			$0.height.equalTo(7)
			$0.trailing.equalToSuperview().inset(30)
			$0.centerY.equalTo(titleLabel.snp.centerY)
		}
	}
}
