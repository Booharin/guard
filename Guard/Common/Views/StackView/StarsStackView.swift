//
//  StarsStackView.swift
//  Guard
//
//  Created by Alexandr Bukharin on 27.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit
import RxSwift

final class StarsStackView: UIStackView {
	var starsViews = [
		StarImageView(),
		StarImageView(),
		StarImageView(),
		StarImageView(),
		StarImageView()
	]

	private let disposeBag = DisposeBag()

	var selectedCount: Double {
		var count = 0.0
		starsViews.forEach {
			if $0.isSelected {
				count += 1
			}
		}
		return count
	}

	init() {
		super.init(frame: .zero)
		starsViews.indices.forEach { i in
			let starView = starsViews[i]
			addArrangedSubview(starView)
			starView.snp.makeConstraints {
				$0.width.height.equalTo(42)
			}
			starView
				.rx
				.tapGesture()
				.when(.recognized)
				.subscribe(onNext: { [unowned self] _ in
					starView.selected(isOn: !starView.isSelected)
					switch i {
					case 0:
							starsViews[1].selected(isOn: false)
							starsViews[2].selected(isOn: false)
							starsViews[3].selected(isOn: false)
							starsViews[4].selected(isOn: false)
					case 1:
						if starView.isSelected {
							starsViews[0].selected(isOn: true)
							starsViews[2].selected(isOn: false)
							starsViews[3].selected(isOn: false)
							starsViews[4].selected(isOn: false)
						} else {
							starsViews[2].selected(isOn: false)
							starsViews[3].selected(isOn: false)
							starsViews[4].selected(isOn: false)
						}
					case 2:
						if starView.isSelected {
							starsViews[0].selected(isOn: true)
							starsViews[1].selected(isOn: true)
							starsViews[3].selected(isOn: false)
							starsViews[4].selected(isOn: false)
						} else {
							starsViews[3].selected(isOn: false)
							starsViews[4].selected(isOn: false)
						}
					case 3:
						if starView.isSelected {
							starsViews[0].selected(isOn: true)
							starsViews[1].selected(isOn: true)
							starsViews[2].selected(isOn: true)
							starsViews[4].selected(isOn: false)
						} else {
							starsViews[4].selected(isOn: false)
						}
					case 4:
						if starView.isSelected {
							starsViews[0].selected(isOn: true)
							starsViews[1].selected(isOn: true)
							starsViews[2].selected(isOn: true)
							starsViews[3].selected(isOn: true)
						}
					default: break
					}
				}).disposed(by: disposeBag)
		}
		axis = .horizontal
		distribution = .equalSpacing
		spacing = 10
	}

	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
