//
//  LottieAnimationView.swift
//  Guard
//
//  Created by Alexandr Bukharin on 13.02.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import Lottie
import UIKit

final class LottieAnimationView: UIView {
	private let animationView = AnimationView()
	private let animation = Animation.named("hooji9nu", subdirectory: "LottieAnimations")

	init() {
		super.init(frame: .zero)
		addSubview(animationView)
		animationView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}

		animationView.animation = animation
		animationView.contentMode = .scaleAspectFit
		animationView.loopMode = .loop
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func play() {
		animationView.play()
	}

	func stop() {
		animationView.stop()
	}
}
