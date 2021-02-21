//
//  AddIssueButton.swift
//  Guard
//
//  Created by Alexandr Bukharin on 23.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit

final class AddIssueButton: UIButton {

	init(backgroundColor: UIColor = Colors.darkBlueColor) {
		super.init(frame: .zero)
		self.backgroundColor = backgroundColor
		layer.cornerRadius = 11
		addViews()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func addViews() {
		let imageView = UIImageView(image: #imageLiteral(resourceName: "issue_add_icn"))
		addSubview(imageView)
		imageView.snp.makeConstraints {
			$0.width.height.equalTo(9)
			$0.center.equalToSuperview()
		}
	}
}
