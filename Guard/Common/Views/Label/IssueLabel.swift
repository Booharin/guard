//
//  IssueLabel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 27.12.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
import RxSwift

final class IssueLabel: UILabel {
	private let labelColor: UIColor
	private let animationDuration = 0.15
	private var disposeBag = DisposeBag()
	let subIssueCode: Int
	
	var textInsets = UIEdgeInsets.zero {
		didSet { invalidateIntrinsicContentSize() }
	}

	init(labelColor: UIColor,
		 subIssueCode: Int) {

		self.labelColor = labelColor
		self.subIssueCode = subIssueCode
		super.init(frame: .zero)

		backgroundColor = labelColor
		textColor = Colors.whiteColor
		font = SFUIDisplay.medium.of(size: 12)
		numberOfLines = 0
		textAlignment = .center
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
