//
//  SelectSubIssueView.swift
//  Guard
//
//  Created by Alexandr Bukharin on 03.04.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit

final class SelectSubIssueView: UIView {
	var isSelected: Bool
	private let selectView = UIView()
	private let selectImageView = UIImageView(image: #imageLiteral(resourceName: "select_icn"))
	private let titleLabel = UILabel()
	private let subTitleLabel = UILabel()
	let title: String
	var subtitle: String?

	init(title: String,
		 subtitle: String?,
		 isSelected: Bool = false) {
		self.title = title
		self.subtitle = subtitle
		self.isSelected = isSelected
		super.init(frame: .zero)

		addViews()
		setupViews()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func addViews() {
		addSubview(selectView)
		selectView.snp.makeConstraints {
			$0.width.height.equalTo(14)
			$0.top.equalToSuperview().offset(10)
			$0.leading.equalToSuperview().offset(42)
		}
		selectView.backgroundColor = Colors.subIssueBackgroundColor

		selectView.addSubview(selectImageView)
		selectImageView.snp.makeConstraints {
			$0.width.height.equalTo(14)
			$0.center.equalTo(selectView.snp.center)
		}

		addSubview(titleLabel)
		titleLabel.snp.makeConstraints {
			$0.leading.equalToSuperview().offset(70)
			$0.trailing.equalToSuperview().offset(-42)
			$0.top.equalToSuperview().offset(10)
		}

		addSubview(subTitleLabel)
		subTitleLabel.snp.makeConstraints {
			$0.leading.equalToSuperview().offset(70)
			$0.trailing.equalToSuperview().offset(-42)
			$0.top.equalTo(titleLabel.snp.bottom).offset(1)
			$0.bottom.equalToSuperview().offset(-10)
		}

		select(on: isSelected)
	}

	private func setupViews() {
		selectView.layer.cornerRadius = 7

		selectImageView.layer.cornerRadius = 7

		titleLabel.textColor = Colors.mainTextColor
		titleLabel.font = SFUIDisplay.medium.of(size: 12)
		titleLabel.numberOfLines = 0
		titleLabel.text = title

		subTitleLabel.textColor = Colors.mainTextColor
		subTitleLabel.font = SFUIDisplay.light.of(size: 12)
		subTitleLabel.numberOfLines = 0
		subTitleLabel.text = subtitle
	}

	func select(on: Bool) {
		isSelected = on
		selectImageView.isHidden = !isSelected
	}
}
