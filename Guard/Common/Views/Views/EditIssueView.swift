//
//  EditIssueView.swift
//  Guard
//
//  Created by Alexandr Bukharin on 21.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit
import RxSwift

final class EditIssueView: UIView {
	private let editViewColor: UIColor
	private let issueCode: Int
	var editSubject = PublishSubject<Int>()
	private let disposeBag = DisposeBag()

	init(editViewColor: UIColor,
		 issueCode: Int) {

		self.editViewColor = editViewColor
		self.issueCode = issueCode
		super.init(frame: .zero)

		backgroundColor = editViewColor
		layer.cornerRadius = 11
		layer.borderWidth = 1
		layer.borderColor = editViewColor.cgColor
		clipsToBounds = true
		
		let imageView = UIImageView(image: #imageLiteral(resourceName: "issue_remove_icn"))
		addSubview(imageView)
		imageView.snp.makeConstraints {
			$0.width.height.equalTo(9)
			$0.trailing.equalToSuperview().offset(-10)
			$0.centerY.equalToSuperview()
		}

		imageView
			.rx
			.tapGesture()
			.when(.recognized)
			.subscribe(onNext: { [unowned self] _ in
				self.editSubject.onNext(self.issueCode)
			}).disposed(by: disposeBag)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}
