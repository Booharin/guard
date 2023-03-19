//
//  LottieAnimationView.swift
//  Guard
//
//  Created by Alexandr Bukharin on 13.02.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import Lottie
import UIKit

final class AnimationView: UIView {
    private var animationView: LottieAnimationView?
	//private let animation = Animation.named("ifegughi", subdirectory: "LottieAnimations")

	init() {
		super.init(frame: .zero)

        animationView = .init(name: "ifegughi")
        guard let animationView = animationView else { return }
		addSubview(animationView)
		animationView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}

		//animationView.animation = animation
		animationView.contentMode = .scaleAspectFit
		animationView.loopMode = .loop
		isHidden = true
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func play() {
		isHidden = false
		animationView?.play()
	}

	func stop() {
		isHidden = true
		animationView?.stop()
	}
}
