//
//  AlertService.swift
//  Guard
//
//  Created by Alexandr Bukharin on 11.10.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol HasAlertService {
	var alertService: AlertServiceInterface { get set }
}
/// Interface of service for showing services
protocol AlertServiceInterface {
	/// Method for showing Alert
	/// - Parameters:
	///   - title: Title
	///   - message: Message
	///   - completion: Result
	func showAlert(title: String,
				   message: String,
				   okButtonTitle: String,
				   cancelButtonTitle: String?,
				   completion: @escaping (Bool) -> Void)
}

extension AlertServiceInterface {
	func showAlert(title: String,
				   message: String,
				   okButtonTitle: String,
				   cancelButtonTitle: String? = nil,
				   completion: @escaping (Bool) -> Void) {

		showAlert(title: title,
				  message: message,
				  okButtonTitle: okButtonTitle,
				  cancelButtonTitle: cancelButtonTitle,
				  completion: completion)
	}
}

/// Service for showing services
final class AlertService: AlertServiceInterface {
	private var dimmView: UIView?
	private var alertView: UIView?
	private let animationDuration = 0.15
	private let alertShowAnimationDuration = 0.15
	private var disposeBag = DisposeBag()

	var currentWindow: UIWindow? {
		return UIApplication.shared.windows.first
	}

	var screenHeight: CGFloat {
		UIScreen.main.bounds.height
	}

	var screenWidth: CGFloat {
		UIScreen.main.bounds.width
	}

	func showAlert(title: String,
				   message: String,
				   okButtonTitle: String,
				   cancelButtonTitle: String? = nil,
				   completion: @escaping (Bool) -> Void) {

		guard let window = currentWindow else { return }
		// dimm
		dimmView = UIView()
		guard let dimmView = dimmView else { return }
		window.addSubview(dimmView)
		dimmView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
		dimmView
			.rx
			.tapGesture()
			.when(.recognized)
			.subscribe(onNext: { [weak self] _ in
				self?.dismissAlertView()
			}).disposed(by: disposeBag)
		// alert
		alertView = UIView()
		guard let alertView = alertView else { return }
		alertView.layer.cornerRadius = 17
		alertView.backgroundColor = Colors.whiteColor
		dimmView.addSubview(alertView)
		alertView.snp.makeConstraints {
			$0.bottom.equalTo(window.snp.bottom).offset(screenHeight / 2)
			$0.centerX.equalToSuperview()
			$0.width.equalTo(305)
			$0.height.lessThanOrEqualTo(220)
		}
		// title
		let titleLabel = UILabel()
		titleLabel.font = Saira.medium.of(size: 18)
		titleLabel.textAlignment = .center
		titleLabel.numberOfLines = 0
		titleLabel.text = title
		alertView.addSubview(titleLabel)
		titleLabel.snp.makeConstraints {
			$0.top.equalToSuperview().offset(13)
			$0.leading.equalToSuperview().offset(35)
			$0.trailing.equalToSuperview().offset(-35)
		}
		// message
		let messageLabel = UILabel()
		messageLabel.font = SFUIDisplay.regular.of(size: 15)
		messageLabel.textAlignment = .center
		messageLabel.numberOfLines = 0
		messageLabel.text = message
		alertView.addSubview(messageLabel)
		messageLabel.snp.makeConstraints {
			$0.top.equalTo(titleLabel.snp.bottom).offset(20)
			$0.leading.equalToSuperview().offset(35)
			$0.trailing.equalToSuperview().offset(-35)
		}

		// ok button
		let okButton = UIButton()
		okButton.setTitle(okButtonTitle,
							  for: .normal)
		okButton.backgroundColor = Colors.greenColor
		okButton.layer.cornerRadius = 25
		alertView.addSubview(okButton)
		okButton.snp.makeConstraints {
			$0.height.equalTo(50)
			if cancelButtonTitle == nil {
				$0.centerX.equalToSuperview()
				$0.width.equalTo(136)
			} else {
				$0.trailing.lessThanOrEqualToSuperview().offset(-35)
				$0.width.equalTo(108)
			}
			$0.top.equalTo(messageLabel.snp.bottom).offset(24)
			$0.bottom.equalToSuperview().offset(-14)
		}
		okButton.rx
			.tap
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					okButton.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						okButton.alpha = 1
					})
				})
			})
			.subscribe(onNext: { [weak self] _ in
				self?.dismissAlertView()
				completion(true)
			}).disposed(by: disposeBag)

		// cancel button
		if let cancelTitle = cancelButtonTitle {
		
		let cancelButton = UIButton()
		cancelButton.setTitle(cancelTitle,
							  for: .normal)
		cancelButton.backgroundColor = Colors.warningColor
		cancelButton.layer.cornerRadius = 25
		alertView.addSubview(cancelButton)
		cancelButton.snp.makeConstraints {
			$0.height.equalTo(50)
			$0.width.equalTo(108)
			$0.leading.lessThanOrEqualToSuperview().offset(35)
			$0.top.equalTo(messageLabel.snp.bottom).offset(24)
			$0.bottom.equalToSuperview().offset(-14)
		}
		cancelButton.rx
			.tap
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					cancelButton.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						cancelButton.alpha = 1
					})
				})
			})
			.subscribe(onNext: { [weak self] _ in
				self?.dismissAlertView()
				completion(false)
			}).disposed(by: disposeBag)
		}

		window.layoutIfNeeded()

		// animate show
		alertView.snp.updateConstraints {
			$0.bottom.equalTo(window.snp.bottom).offset(-self.screenHeight / 2)
		}
		UIView.animate(withDuration: alertShowAnimationDuration,
					   delay: 0,
					   options: .curveEaseOut,
					   animations: {
			dimmView.backgroundColor = Colors.blackColor.withAlphaComponent(0.6)
			window.layoutIfNeeded()
		})
	}

	/// Hide alert
	private func dismissAlertView() {
		guard
			let alertView = alertView,
			let dimmView = dimmView,
			let window = currentWindow else { return }

		alertView.snp.updateConstraints {
			$0.bottom.equalTo(window.snp.bottom).offset(screenHeight / 2)
		}
		UIView.animate(withDuration: alertShowAnimationDuration,
					   delay: 0,
					   options: .curveEaseInOut,
					   animations: {
			dimmView.backgroundColor = .clear
			window.layoutIfNeeded()
		}, completion: { _ in
			self.alertView?.removeFromSuperview()
			self.alertView = nil
			self.dimmView?.removeFromSuperview()
			self.dimmView = nil
		})
	}
}
