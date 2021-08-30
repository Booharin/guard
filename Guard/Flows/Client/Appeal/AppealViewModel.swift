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
	private var appeal: ClientAppeal
	typealias Dependencies =
		HasLocalStorageService &
		HasAppealsNetworkService &
		HasCommonDataNetworkService &
		HasAlertService
	lazy var di: Dependencies = DI.dependencies
	var isEditingSubject = PublishSubject<Bool>()
	private let toCreateAppealSubject = PublishSubject<IssueType>()
	private let changeStatusSubject = PublishSubject<Bool>()
	private var issueTitle: String?

	init(appeal: ClientAppeal) {
		self.appeal = appeal
	}

	func viewDidSet() {
		// set issue title
		di.commonDataNetworkService.subIssueTypes?.forEach {
			if appeal.subIssueCode == $0.subIssueCode {
				issueTitle = $0.title
			}
		}

		// swipe to go back
		view.view
			.rx
			.swipeGesture(.right)
			.when(.recognized)
			.subscribe(onNext: { [unowned self] _ in
				self.view.navController?.popViewController(animated: true)
			}).disposed(by: disposeBag)

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

		// issue type label
		view.issueTypeView.backgroundColor = Colors.warningColor
		view.issueTypeView.layer.cornerRadius = 12
		view.issueTypeView.isHidden = issueTitle == nil

		view.issueTypeLabel.font = SFUIDisplay.medium.of(size: 15)
		view.issueTypeLabel.textColor = Colors.whiteColor
		view.issueTypeLabel.numberOfLines = 0
		view.issueTypeLabel.isHidden = issueTitle == nil
		view.issueTypeLabel.text = issueTitle
		view.issueTypeLabel.textAlignment = .center

		view.issueTypeView
			.rx
			.tapGesture()
			.when(.recognized)
			.filter { _ in
				self.view.titleTextField.isUserInteractionEnabled == true
			}
			.do(onNext: { [unowned self] _ in
				UIView.animate(withDuration: self.animationDuration, animations: {
					self.view.issueTypeLabel.alpha = 0.5
				}, completion: { _ in
					UIView.animate(withDuration: self.animationDuration, animations: {
						self.view.issueTypeLabel.alpha = 1
					})
				})
			})
			.subscribe(onNext: { [weak self] _ in
				let selectIssueController = SelectIssueViewController(viewModel:
																		SelectIssueViewModel(toMainSubject: self?.toCreateAppealSubject))
				selectIssueController.hidesBottomBarWhenPushed = true
				self?.view.navController?.pushViewController(selectIssueController, animated: true)
			}).disposed(by: disposeBag)

		view.lawyerSelectedButton.backgroundColor = Colors.greenColor
		view.lawyerSelectedButton.layer.cornerRadius = 25
		view.lawyerSelectedButton.setTitle(
			appeal.lawyerChoosed ?? false ?
				"appeal.lawyerNotSelectedButton.title".localized.uppercased() :
				"appeal.lawyerSelectedButton.title".localized.uppercased(),
			for: .normal)

		// save button
		view.lawyerSelectedButton
			.rx
			.tap
			.filter {
				if self.view.titleTextField.isUserInteractionEnabled == true {
					return true
				} else {
					let alertTitle = self.appeal.lawyerChoosed ?? false ?
						"appeal.notChoosed".localized : "appeal.lawyerChoosed".localized
					let alertMessage = self.appeal.lawyerChoosed ?? false ?
						"appeal.notChoosed.subtitle".localized : "appeal.lawyerChoosed.subtitle".localized

					self.di.alertService.showAlert(title: alertTitle,
												   message: alertMessage,
												   okButtonTitle: "alert.yes".localized.uppercased(),
												   cancelButtonTitle: "alert.no".localized.uppercased()) { result in
						if result {
							self.view.loadingView.play()
							self.changeStatusSubject.onNext(!(self.appeal.lawyerChoosed ?? false))
						}
					}
					return false
				}
			}
			.do(onNext: { [unowned self] _ in
				self.view.lawyerSelectedButton.animateBackground()
				self.view.loadingView.play()
			})
			.flatMap { [unowned self] _ in
				self.di.appealsNetworkService
					.editAppeal(title: self.view.titleTextField.text ?? "",
								appealDescription: self.view.descriptionTextView.text ?? "",
								appeal: self.appeal,
								cityCode: self.di.localStorageService.getCurrenClientProfile()?.cityCode?.first ?? 99)
			}
			.subscribe(onNext: { [weak self] result in
				self?.view.loadingView.stop()
				switch result {
				case .success:
					self?.isEditingSubject.onNext(false)
					self?.view.navController?.popViewController(animated: true)
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

		toCreateAppealSubject
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [unowned self] issueType in
				self.appeal.changeSubIssue(with: issueType.subIssueCode ?? 0)
				self.di.commonDataNetworkService.subIssueTypes?.forEach {
					if self.appeal.subIssueCode == $0.subIssueCode {
						self.issueTitle = $0.title
						self.view.issueTypeLabel.text = issueTitle
					}
				}
				if self.view.navController?.viewControllers.count ?? 0 > 1,
				   let vc = self.view.navController?.viewControllers[1] {
					self.view.navController?.popToViewController(vc, animated: true)
				}
			})
			.disposed(by: disposeBag)

		changeStatusSubject
			.asObservable()
			.flatMap { [unowned self] status in
				self.di.appealsNetworkService.changeAppealStatus(with: self.appeal.id,
																 status: status)
			}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] result in
				self?.view.loadingView.stop()
				switch result {
					case .success:
						self?.appeal.lawyerChoosed(isChoosed: !(self?.appeal.lawyerChoosed ?? false))
						self?.view.lawyerSelectedButton.setTitle(
							self?.appeal.lawyerChoosed ?? false ?
								"appeal.lawyerNotSelectedButton.title".localized.uppercased() : "appeal.lawyerSelectedButton.title".localized.uppercased(),
							for: .normal)
					case .failure(let error):
						//TODO: - обработать ошибку
						print(error.localizedDescription)
				}
			}).disposed(by: disposeBag)
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
