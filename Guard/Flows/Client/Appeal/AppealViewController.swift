//
//  AppealViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 14.10.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

protocol AppealViewControllerProtocol: ViewControllerProtocol {
	var backButtonView: BackButtonView { get }
	var cancelButton: SkipButton { get }
	var threedotsButton: ThreeDotsButton { get }
	var rightBarButtonItem: UIBarButtonItem? { get set }
	var titleView: UIView { get }
	var titleTextField: TextField { get }
	var issueTypeLabel: UILabel { get }
	var descriptionTextView: UITextView { get }
	var lawyerSelectedButton: ConfirmButton { get }
	var loadingView: LottieAnimationView { get }
	func showActionSheet()
}

final class AppealViewController<modelType: AppealViewModel>:
	UIViewController,
	UITableViewDelegate,
	UITextViewDelegate,
	AppealViewControllerProtocol {

	var viewModel: modelType
	var backButtonView = BackButtonView()
	var cancelButton = SkipButton(title: "appeal.cancelButton.title".localized,
								  font: Saira.medium.of(size: 16))
	var threedotsButton = ThreeDotsButton()
	var rightBarButtonItem: UIBarButtonItem? {
		get {
			self.navigationItem.rightBarButtonItem
		}
		set {
			self.navigationItem.rightBarButtonItem = newValue
		}
	}
	var titleView = UIView()
	var titleTextField = TextField()
	var issueTypeLabel = UILabel()
	var descriptionTextView = UITextView()
	var lawyerSelectedButton = ConfirmButton(title: "appeal.lawyerSelectedButton.title".localized.uppercased(),
											 backgroundColor: Colors.greenColor)
	var navController: UINavigationController? {
		self.navigationController
	}
	var loadingView = LottieAnimationView()

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
		let rightBarButtonItem = UIBarButtonItem(customView: threedotsButton)
		self.navigationItem.leftBarButtonItem = leftBarButtonItem
		self.navigationItem.rightBarButtonItem = rightBarButtonItem
		self.navigationItem.titleView = titleView
	}

	private func addViews() {
		// title
		titleView.addSubview(titleTextField)
		titleTextField.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.centerY.equalToSuperview().offset(2)
			$0.width.lessThanOrEqualTo(250)
		}
		titleView.snp.makeConstraints {
			$0.width.equalTo(titleTextField.snp.width).offset(46)
			$0.height.equalTo(40)
		}
		// issue type
		view.addSubview(issueTypeLabel)
		issueTypeLabel.snp.makeConstraints {
			$0.height.equalTo(24)
			$0.top.equalToSuperview().offset(90)
			$0.centerX.equalToSuperview()
			$0.width.lessThanOrEqualTo(300).priority(1000)
			$0.width.equalTo(issueTypeLabel.intrinsicContentSize.width + 20).priority(900)
		}
		// description text view
		descriptionTextView.delegate = self
		view.addSubview(descriptionTextView)
		descriptionTextView.snp.makeConstraints {
			$0.leading.equalToSuperview().offset(36)
			$0.trailing.equalToSuperview().offset(-36)
			$0.top.equalTo(issueTypeLabel.snp.bottom).offset(23)
			$0.bottom.equalToSuperview().offset(-160)
		}
		view.addSubview(lawyerSelectedButton)
		lawyerSelectedButton.snp.makeConstraints {
			$0.height.equalTo(50)
			$0.leading.equalToSuperview().offset(36)
			$0.trailing.equalToSuperview().offset(-36)
			$0.bottom.equalToSuperview().offset(-100)
		}
		// loading view
		view.addSubview(loadingView)
		loadingView.snp.makeConstraints {
			$0.center.equalToSuperview()
			$0.width.height.equalTo(300)
		}
	}

	// MARK: - Show edit action sheet
	func showActionSheet() {
		let alertController = UIAlertController(title: nil,
												message: nil,
												preferredStyle: .actionSheet)
		alertController.view.tintColor = Colors.mainTextColor
		let editAction = UIAlertAction(title: "appeal.edit.title".localized,
									   style: .default,
									   handler: { _ in
										self.viewModel.isEditingSubject.onNext(true)
										alertController.dismiss(animated: true)
									   })
		alertController.addAction(editAction)
		let cancelAction = UIAlertAction(title: "alert.cancel".localized,
										 style: .cancel,
										 handler: { _ in
											alertController.dismiss(animated: true)
										 })
		alertController.addAction(cancelAction)
		self.present(alertController, animated: true)
	}

	// MARK: - TextView delegate
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
