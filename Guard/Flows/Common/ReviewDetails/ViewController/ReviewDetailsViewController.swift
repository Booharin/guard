//
//  ReviewDetailsViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 27.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit

protocol ReviewDetailsViewControllerProtocol: ViewControllerProtocol {
	var backButtonView: BackButtonView { get }
	var titleView: UIView { get }
	var titleLabel: UILabel { get }
	var starsStackView: StarsStackView { get }

	var reviewerName: UILabel { get }
	var descriptionTextView: UITextView { get }
	var createReviewButton: ConfirmButton { get }
	var loadingView: AnimationView { get }
}

final class ReviewDetailsViewController<modelType: ReviewDetailsViewModel>:
	UIViewController,
	UITextViewDelegate,
	ReviewDetailsViewControllerProtocol {

	var backButtonView = BackButtonView()
	var titleView = UIView()
	var titleLabel = UILabel()
	var starsStackView = StarsStackView()

	var reviewerName = UILabel()
	var descriptionTextView = UITextView()
	var createReviewButton = ConfirmButton(title: "new_review.create_button.titile".localized.uppercased())

	var loadingView = AnimationView()
	var navController: UINavigationController? {
		self.navigationController
	}
	var viewModel: modelType

	init(viewModel: modelType) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.viewModel.assosiateView(self)
		view.backgroundColor = Colors.whiteColor
		addViews()
		setNavigationBar()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.isNavigationBarHidden = false
		self.navigationItem.setHidesBackButton(true, animated:false)
	}
	
	func setNavigationBar() {
		let leftBarButtonItem = UIBarButtonItem(customView: backButtonView)
		self.navigationItem.leftBarButtonItem = leftBarButtonItem

		self.navigationItem.titleView = titleView
	}
	
	private func addViews() {
		// title view
		titleView.addSubview(titleLabel)
		titleLabel.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.centerY.equalToSuperview().offset(2)
			$0.width.lessThanOrEqualTo(250)
		}
		titleView.snp.makeConstraints {
			$0.width.equalTo(titleLabel.snp.width).offset(46)
			$0.height.equalTo(40)
		}
		view.addSubview(starsStackView)
		starsStackView.snp.makeConstraints {
			$0.width.equalTo(250)
			$0.height.equalTo(42)
			$0.centerX.equalToSuperview()
			$0.top.equalToSuperview().offset(100)
		}
		view.addSubview(reviewerName)
		reviewerName.snp.makeConstraints {
			$0.top.equalTo(starsStackView.snp.bottom).offset(20)
			$0.leading.equalToSuperview().offset(36)
			$0.trailing.equalToSuperview().offset(-36)
		}
		// description text view
		descriptionTextView.delegate = self
		view.addSubview(descriptionTextView)
		descriptionTextView.snp.makeConstraints {
			$0.leading.equalToSuperview().offset(36)
			$0.trailing.equalToSuperview().offset(-36)
			$0.top.equalTo(reviewerName.snp.bottom).offset(19)
			$0.bottom.equalToSuperview().offset(-140)
		}
		// separator view
		let separatorView = UIView()
		separatorView.backgroundColor = Colors.separatorColor
		view.addSubview(separatorView)
		separatorView.snp.makeConstraints {
			$0.height.equalTo(1)
			$0.bottom.equalTo(descriptionTextView.snp.top).offset(-10)
			$0.width.equalTo(130)
			$0.centerX.equalToSuperview()
		}
		// bottom separator view
		let bottomSeparatorView = UIView()
		bottomSeparatorView.backgroundColor = Colors.separatorColor
		view.addSubview(bottomSeparatorView)
		bottomSeparatorView.snp.makeConstraints {
			$0.height.equalTo(1)
			$0.top.equalTo(descriptionTextView.snp.bottom).offset(10)
			$0.width.equalTo(130)
			$0.centerX.equalToSuperview()
		}
		// create button
		view.addSubview(createReviewButton)
		createReviewButton.snp.makeConstraints {
			$0.height.equalTo(50)
			$0.bottom.equalToSuperview().offset(-30)
			$0.centerX.equalToSuperview()
		}
		// loading view
		view.addSubview(loadingView)
		loadingView.snp.makeConstraints {
			$0.center.equalToSuperview()
			$0.width.height.equalTo(300)
		}
	}

	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.textColor == Colors.placeholderColor {
			textView.text = nil
			textView.textColor = Colors.mainTextColor
			textView.font = SFUIDisplay.regular.of(size: 16)
			textView.textAlignment = .natural
		}
	}

	func textViewDidEndEditing(_ textView: UITextView) {
		if textView.text.isEmpty {
			textView.text = "new_review.textview.placeholder".localized
			textView.textColor = Colors.placeholderColor
			textView.font = Saira.light.of(size: 15)
			textView.textAlignment = .center
		}
	}

	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		if(text == "\n") {
			textView.resignFirstResponder()
			return false
		}
		return true
	}
}
