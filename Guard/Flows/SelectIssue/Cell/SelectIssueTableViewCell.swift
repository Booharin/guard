//
//  SelectIssueTableViewCell.swift
//  Guard
//
//  Created by Alexandr Bukharin on 21.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

class SelectIssueTableViewCell: UITableViewCell {
	
	private let issueTitle = UILabel()
	private let separatorView = UIView()
	
	var viewModel: SelectIssueCellViewModel! {
        didSet {
            self.configure()
        }
    }

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		addViews()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func addViews() {
		addSubview(issueTitle)
		issueTitle.snp.makeConstraints() {
			$0.top.equalToSuperview().offset(8)
			$0.leading.equalToSuperview().offset(15)
			$0.trailing.equalToSuperview().offset(-15)
			$0.bottom.equalToSuperview().offset(-8)
			$0.height.greaterThanOrEqualTo(45)
		}
		addSubview(separatorView)
		separatorView.snp.makeConstraints {
			$0.height.equalTo(1)
			$0.leading.equalToSuperview().offset(20)
			$0.bottom.trailing.equalToSuperview()
		}
	}
	
	private func configure() {
        issueTitle.text = viewModel.title
		issueTitle.textColor = Colors.white
		issueTitle.numberOfLines = 0
		backgroundColor = Colors.authCellsBackground
		separatorView.backgroundColor = Colors.separator
		selectionStyle = .none
    }
}
