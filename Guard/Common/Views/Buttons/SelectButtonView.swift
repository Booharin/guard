//
//  SelectButtonView.swift
//  Guard
//
//  Created by Alexandr Bukharin on 11.10.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

final class SelectButtonView: UIView {
	var titleText = ""
	let isSeparatorHidden: Bool
	var titleLabel = UILabel()
	private var separatorView = UIView()

	init(isSeparatorHidden: Bool = false) {
		self.isSeparatorHidden = isSeparatorHidden
		super.init(frame: .zero)
		addViews()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func addViews() {
		// title
		addSubview(titleLabel)
		titleLabel.textColor = Colors.mainTextColor
		titleLabel.font = SFUIDisplay.medium.of(size: 15)
		//titleLabel.text = titleText
		titleLabel.snp.makeConstraints {
			$0.center.equalToSuperview()
			$0.width.lessThanOrEqualTo(200)
			$0.height.equalTo(20)
		}
		// chevron
		let chevronImageView = UIImageView(image: #imageLiteral(resourceName: "location_chevron_down").withRenderingMode(.alwaysTemplate))
		chevronImageView.tintColor = Colors.mainColor
		addSubview(chevronImageView)
		chevronImageView.snp.makeConstraints {
			$0.width.height.equalTo(6)
			$0.centerY.equalToSuperview()
			$0.leading.equalTo(titleLabel.snp.trailing).offset(7)
		}
		// separator
		separatorView.backgroundColor = Colors.separatorColor
		separatorView.isHidden = isSeparatorHidden
		addSubview(separatorView)
		separatorView.snp.makeConstraints() {
			$0.width.equalTo(130)
			$0.centerX.equalToSuperview()
			$0.bottom.equalToSuperview()
			$0.height.equalTo(1)
		}
	}
}
