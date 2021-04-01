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
	var issuesubtitle: UILabel { get }
	var issueImageView: UIImageView { get }
}

class SelectIssueTableViewCell: UITableViewCell, SelectIssueTableViewCellProtocol {
	
	var containerView = UIView()
	var issueTitle = UILabel()
	var issuesubtitle = UILabel()
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
		contentView.addSubview(containerView)
		containerView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
		containerView.addSubview(issueTitle)
		issueTitle.snp.makeConstraints() {
			$0.leading.equalToSuperview().offset(77)
			$0.trailing.equalToSuperview().offset(-36)
			$0.top.equalToSuperview().offset(5)
		}
		containerView.addSubview(issuesubtitle)
		issuesubtitle.snp.makeConstraints() {
			$0.leading.equalToSuperview().offset(77)
			$0.trailing.equalToSuperview().offset(-36)
			$0.top.equalTo(issueTitle.snp.bottom).offset(4)
			$0.bottom.equalToSuperview().offset(-10)
		}
		containerView.addSubview(issueImageView)
		issueImageView.snp.makeConstraints() {
			$0.leading.equalToSuperview().offset(30)
			$0.width.height.equalTo(30)
			$0.top.equalToSuperview().offset(5)
		}
	}
}
