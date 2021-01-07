//
//  AppealCreatingViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 12.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

protocol AppealCreatingViewControllerProtocol: class, ViewControllerProtocol {
	var backButtonView: BackButtonView { get }
	var titleView: UIView { get }
	var titleLabel: UILabel { get }
	var subtitleLabel: UILabel { get }
	var issueTitleLabel: UILabel { get }
	var titleTextField: TextField { get }
	var descriptionTextView: UITextView { get }
	var createAppealButton: ConfirmButton { get }
	var loadingView: UIActivityIndicatorView { get }
}

final class AppealCreatingViewController<modelType: ViewModel>: UIViewController, UITextViewDelegate,
AppealCreatingViewControllerProtocol where modelType.ViewType == AppealCreatingViewControllerProtocol {

	var backButtonView = BackButtonView()
	var titleView = UIView()
	var titleLabel = UILabel()
	var subtitleLabel = UILabel()
	var issueTitleLabel = UILabel()
	var titleTextField = TextField()
	var descriptionTextView = UITextView()
	var createAppealButton = ConfirmButton(title: "new_appeal.button.title".localized.uppercased())
	var navController: UINavigationController? {
		return self.navigationController
	}
	var loadingView = UIActivityIndicatorView(style: .medium)
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
		// subtitle
		view.addSubview(subtitleLabel)
		subtitleLabel.snp.makeConstraints {
			$0.height.equalTo(24)
			$0.top.equalToSuperview().offset(97)
			$0.centerX.equalToSuperview()
		}
		view.addSubview(issueTitleLabel)
		issueTitleLabel.snp.makeConstraints {
			$0.top.equalTo(subtitleLabel.snp.bottom).offset(15)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
		}
		// title text field
		view.addSubview(titleTextField)
		titleTextField.snp.makeConstraints {
			$0.height.equalTo(48)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
			$0.top.equalTo(issueTitleLabel.snp.bottom).offset(10)
		}
		// description text view
		descriptionTextView.delegate = self
		view.addSubview(descriptionTextView)
		descriptionTextView.snp.makeConstraints {
			$0.leading.equalToSuperview().offset(36)
			$0.trailing.equalToSuperview().offset(-36)
			$0.top.equalTo(titleTextField.snp.bottom).offset(19)
			$0.bottom.equalToSuperview().offset(-140)
		}
		// separator view
		let separatorView = UIView()
		separatorView.backgroundColor = Colors.separatorColor
		view.addSubview(separatorView)
		separatorView.snp.makeConstraints {
			$0.height.equalTo(1)
			$0.top.equalTo(descriptionTextView.snp.bottom).offset(10)
			$0.width.equalTo(130)
			$0.centerX.equalToSuperview()
		}
		// create button
		view.addSubview(createAppealButton)
		createAppealButton.snp.makeConstraints {
			$0.height.equalTo(50)
			$0.bottom.equalToSuperview().offset(-30)
			$0.centerX.equalToSuperview()
		}
		// loading view
		view.addSubview(loadingView)
		loadingView.hidesWhenStopped = true
		loadingView.snp.makeConstraints {
			$0.center.equalTo(view.snp.center)
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
			textView.text = "new_appeal.textview.placeholder".localized
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
