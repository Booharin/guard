//
//  AppealViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 14.10.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class AppealViewModel: ViewModel, HasDependencies {
	var view: AppealViewControllerProtocol!
	private let animationDuration = 0.15
	private var disposeBag = DisposeBag()
	private let appeal: ClientAppeal
	typealias Dependencies =
		HasLocalStorageService &
		HasAppealsNetworkService &
		HasCommonDataNetworkService
	lazy var di: Dependencies = DI.dependencies
	var isEditingSubject = PublishSubject<Bool>()
	private var issueTitle: String?

	init(appeal: ClientAppeal) {
		self.appeal = appeal
	}

	func viewDidSet() {
		// set issue title
		di.commonDataNetworkService.subIssueTypes?.forEach {
			if appeal.issueCode == $0.subIssueCode {
				issueTitle = $0.title
			}
		}

		// back button
		view.backButtonView
			.rx
			.tapGesture()
			.when(.recognized)
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.backButtonView.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.backButtonView.alpha = 1
					})
				})
			})
			.subscribe(onNext: { [weak self] _ in
				self?.view.navController?.popViewController(animated: true)
			}).disposed(by: disposeBag)

		// three dots button
		view.threedotsButton
			.rx
			.tapGesture()
			.when(.recognized)
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.threedotsButton.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.threedotsButton.alpha = 1
					})
				})
			})
			.subscribe(onNext: { [weak self] _ in
				self?.view.showActionSheet()
			}).disposed(by: disposeBag)

		// three dots button
		view.cancelButton
			.rx
			.tapGesture()
			.when(.recognized)
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.cancelButton.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.cancelButton.alpha = 1
					})
				})
			})
			.subscribe(onNext: { [weak self] _ in
				self?.view.view.endEditing(true)
				self?.isEditingSubject.onNext(false)
			}).disposed(by: disposeBag)

		// title
		view.titleTextField.configure(placeholderText: "new_appeal.title.textfield.placeholder".localized,
									  isSeparatorHidden: true)
		view.titleTextField
			.rx
			.text
			.subscribe(onNext: { _ in
				self.checkAreTextFieldsEmpty()
			}).disposed(by: disposeBag)
		view.titleTextField.text = appeal.title
		view.titleTextField.isUserInteractionEnabled = false

		// text view
		view.descriptionTextView.isEditable = false
		view.descriptionTextView.textColor = Colors.mainTextColor
		view.descriptionTextView.text = "new_appeal.textview.placeholder".localized
		view.descriptionTextView.font = SFUIDisplay.regular.of(size: 16)
		view.descriptionTextView.textAlignment = .natural
		view.descriptionTextView.backgroundColor = Colors.whiteColor
		view.descriptionTextView
			.rx
			.text
			.subscribe(onNext: { [unowned self] _ in
				self.checkAreTextFieldsEmpty()
			}).disposed(by: disposeBag)
		view.descriptionTextView.text = appeal.appealDescription

		view.issueTypeLabel.font = SFUIDisplay.medium.of(size: 15)
		view.issueTypeLabel.textColor = Colors.whiteColor
		view.issueTypeLabel.backgroundColor = Colors.warningColor
		view.issueTypeLabel.layer.cornerRadius = 12
		view.issueTypeLabel.clipsToBounds = true

		view.issueTypeLabel.isHidden = issueTitle == nil
		view.issueTypeLabel.text = issueTitle
		view.issueTypeLabel.textAlignment = .center

		view.lawyerSelectedButton.backgroundColor = Colors.greenColor
		view.lawyerSelectedButton.layer.cornerRadius = 25

		// save button
		view.lawyerSelectedButton
			.rx
			.tap
			.filter {
				self.view.lawyerSelectedButton.titleLabel?.text == "appeal.saveButton.title".localized.uppercased()
			}
			.do(onNext: { [unowned self] _ in
				self.view.lawyerSelectedButton.animateBackground()
				self.view.loadingView.startAnimating()
			})
			.flatMap { [unowned self] _ in
				self.di.appealsNetworkService
					.editAppeal(title: self.view.titleTextField.text ?? "",
								appealDescription: self.view.descriptionTextView.text ?? "",
								appeal: self.appeal,
								cityCode: self.di.localStorageService.getCurrenClientProfile()?.cityCode?.first ?? 99)
			}
			.subscribe(onNext: { [weak self] result in
				self?.view.loadingView.stopAnimating()
				switch result {
				case .success:
					self?.isEditingSubject.onNext(false)
				case .failure(let error):
					//TODO: - обработать ошибку
					print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)

		isEditingSubject
			.asObservable()
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [unowned self] isEditing in
				if isEditing {
					self.view.titleTextField.isUserInteractionEnabled = true
					self.view.descriptionTextView.isEditable = true
					self.view.lawyerSelectedButton.setTitle("appeal.saveButton.title".localized.uppercased(),
															 for: .normal)
					self.view.rightBarButtonItem = UIBarButtonItem(customView: self.view.cancelButton)
				} else {
					self.view.titleTextField.isUserInteractionEnabled = false
					self.view.descriptionTextView.isEditable = false
					self.view.lawyerSelectedButton.setTitle("appeal.lawyerSelectedButton.title".localized.uppercased(),
															 for: .normal)
					self.view.rightBarButtonItem = UIBarButtonItem(customView: self.view.threedotsButton)
				}
			}).disposed(by: disposeBag)

		// MARK: - Check keyboard showing
		keyboardHeight()
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [unowned self] keyboardHeight in
				if keyboardHeight > 0 {
					guard self.view.descriptionTextView.textColor == Colors.mainTextColor else { return }
					self.view.descriptionTextView.contentInset = UIEdgeInsets(top: 0,
																			  left: 0,
																			  bottom: keyboardHeight,
																			  right: 0)
				} else {
					self.view.descriptionTextView.contentInset = UIEdgeInsets(top: 0,
																			  left: 0,
																			  bottom: 0,
																			  right: 0)
				}
			})
			.disposed(by: disposeBag)
	}

	private func checkAreTextFieldsEmpty() {
		guard
			let title = view.titleTextField.text,
			let description = view.descriptionTextView.text else { return }

		if !title.isEmpty,
			!description.isEmpty {
			view.lawyerSelectedButton.isEnabled = true
			view.lawyerSelectedButton.backgroundColor = Colors.greenColor
		} else {
			view.lawyerSelectedButton.isEnabled = false
			view.lawyerSelectedButton.backgroundColor = Colors.buttonDisabledColor
		}
	}

	private func keyboardHeight() -> Observable<CGFloat> {
		return Observable
			.from([
				NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
					.map { notification -> CGFloat in
						(notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
				},
				NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
					.map { _ -> CGFloat in
						0
				}
			])
			.merge()
	}

	func removeBindings() {}
}
