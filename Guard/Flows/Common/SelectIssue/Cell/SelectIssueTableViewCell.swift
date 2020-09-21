//
//  SelectIssueTableViewCell.swift
//  Guard
//
//  Created by Alexandr Bukharin on 21.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

protocol SelectIssueTableViewCellProtocol {
	var containerView: UIView { get }
	var issueTitle: UILabel { get }
	var issueImageView: UIImageView { get }
}

class SelectIssueTableViewCell: UITableViewCell, SelectIssueTableViewCellProtocol {
	
	var containerView = UIView()
	var issueTitle = UILabel()
	var issueImageView = UIImageView()
	
	var viewModel: SelectIssueCellViewModel!
	
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
		containerView.addSubview(issueTitle)
		issueTitle.snp.makeConstraints() {
			$0.leading.equalToSuperview().offset(117)
			$0.trailing.equalToSuperview().offset(-50)
			$0.height.equalTo(20)
			$0.top.equalToSuperview().offset(31)
			$0.bottom.equalToSuperview().offset(-31)
		}
		containerView.addSubview(issueImageView)
		issueImageView.snp.makeConstraints() {
			$0.leading.equalToSuperview().offset(35)
			$0.width.height.equalTo(52)
			$0.centerY.equalToSuperview()
		}
	}
}
