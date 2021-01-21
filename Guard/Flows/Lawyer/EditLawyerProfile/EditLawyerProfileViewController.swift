//
//  EditLawyerProfileViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 21.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit

protocol EditLawyerProfileViewControllerProtocol: ViewControllerProtocol {
	var scrollView: UIScrollView { get }
	var backButton: UIButton { get }
	var	confirmButton: UIButton { get }
	var avatarImageView: UIImageView { get }
	var editPhotoView: UIView { get }
	var nameTextField: EditTextField { get }
	var surnameTextField: EditTextField { get }

	var issuesContainerView: UIView { get }

	var phoneTextField: EditTextField { get }
	var emailTextField: EditTextField { get }
	var countrySelectView: SelectButtonView { get }
	var citySelectView: SelectButtonView { get }
	var loadingView: UIActivityIndicatorView { get }
	func showActionSheet(with titles: [String], completion: @escaping (String) -> Void)
	func takePhotoFromGallery()
}

class EditLawyerProfileViewController<modelType: EditLawyerProfileViewModel>:
	UIViewController,
	UITextFieldDelegate,
	UIImagePickerControllerDelegate,
	UINavigationControllerDelegate,
	EditLawyerProfileViewControllerProtocol
{

	var navController: UINavigationController? {
		self.navigationController
	}

	var scrollView = UIScrollView()
	var backButton = UIButton()
	var confirmButton = UIButton()
	var avatarImageView = UIImageView()
	var editPhotoView = UIView()

	var nameTextField = EditTextField()
	var surnameTextField = EditTextField()

	var issuesContainerView = UIView()

	var phoneTextField = EditTextField()
	var emailTextField = EditTextField()
	var countrySelectView = SelectButtonView()
	var citySelectView = SelectButtonView()
	private var imagePicker = UIImagePickerController()
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
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.isNavigationBarHidden = true
		self.navigationItem.setHidesBackButton(true, animated:false)

		viewModel.updateIssuesContainerView()
	}

	private func addViews() {
		// scroll view
		view.addSubview(scrollView)
		scrollView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
		// back button
		scrollView.addSubview(backButton)
		backButton.snp.makeConstraints {
			$0.width.height.equalTo(50)
			$0.top.equalToSuperview()
			$0.leading.equalToSuperview().offset(20)
		}
		// confirm button
		scrollView.addSubview(confirmButton)
		confirmButton.snp.makeConstraints {
			$0.width.height.equalTo(50)
			$0.top.equalToSuperview()
			$0.trailing.equalToSuperview().offset(-20)
		}
		// avatar
		let avatarBackgroundView = UIView()
		avatarBackgroundView.isUserInteractionEnabled = true
		scrollView.addSubview(avatarBackgroundView)
		avatarBackgroundView.snp.makeConstraints {
			$0.width.height.equalTo(158)
			$0.top.equalToSuperview().offset(40)
			$0.centerX.equalToSuperview()
		}
		avatarBackgroundView.layer.borderWidth = 0.5
		avatarBackgroundView.layer.borderColor = Colors.avatarCircle.cgColor
		avatarBackgroundView.layer.cornerRadius = 79
		
		let avatarInnerCircleView = UIView()
		avatarBackgroundView.addSubview(avatarInnerCircleView)
		avatarInnerCircleView.snp.makeConstraints {
			$0.width.height.equalTo(148)
			$0.center.equalToSuperview()
		}
		avatarInnerCircleView.layer.borderWidth = 2
		avatarInnerCircleView.layer.borderColor = Colors.avatarCircle.cgColor
		avatarInnerCircleView.layer.cornerRadius = 74
		avatarInnerCircleView.addSubview(avatarImageView)
		avatarImageView.snp.makeConstraints {
			$0.width.height.equalTo(136)
			$0.center.equalToSuperview()
		}
		avatarImageView.layer.cornerRadius = 68
		avatarImageView.isUserInteractionEnabled = true
		// edit photo view
		avatarImageView.addSubview(editPhotoView)
		editPhotoView.snp.makeConstraints {
			$0.width.height.equalTo(76)
			$0.center.equalTo(avatarImageView.snp.center)
		}
		let cameraImageView = UIImageView(image: #imageLiteral(resourceName: "camera_icn"))
		editPhotoView.addSubview(cameraImageView)
		cameraImageView.snp.makeConstraints {
			$0.width.height.equalTo(38)
			$0.center.equalTo(avatarImageView.snp.center)
		}
		// text fields
		// name
		scrollView.addSubview(nameTextField)
		nameTextField.delegate = self
		nameTextField.snp.makeConstraints {
			$0.width.equalTo(UIScreen.main.bounds.width - 40)
			$0.top.equalTo(avatarBackgroundView.snp.bottom).offset(40)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
			$0.height.equalTo(48)
		}
		// surname
		scrollView.addSubview(surnameTextField)
		surnameTextField.delegate = self
		surnameTextField.snp.makeConstraints {
			$0.top.equalTo(nameTextField.snp.bottom)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
			$0.height.equalTo(48)
		}
		// issue container view
		scrollView.addSubview(issuesContainerView)
		issuesContainerView.snp.makeConstraints {
			$0.top.equalTo(surnameTextField.snp.bottom).offset(12)
			$0.leading.equalToSuperview().offset(35)
			$0.trailing.equalToSuperview().offset(-35)
			$0.height.equalTo(23)
		}
		// issue container view separator
		let separatorView = UIView()
		separatorView.backgroundColor = Colors.separatorColor
		scrollView.addSubview(separatorView)
		separatorView.snp.makeConstraints() {
			$0.width.equalTo(130)
			$0.centerX.equalToSuperview()
			$0.top.equalTo(issuesContainerView.snp.bottom).offset(12)
			$0.height.equalTo(1)
		}
		// phone
		scrollView.addSubview(phoneTextField)
		phoneTextField.delegate = self
		phoneTextField.snp.makeConstraints {
			$0.top.equalTo(separatorView.snp.bottom)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
			$0.height.equalTo(48)
		}
		// email
		scrollView.addSubview(emailTextField)
		emailTextField.delegate = self
		emailTextField.snp.makeConstraints {
			$0.top.equalTo(phoneTextField.snp.bottom)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
			$0.height.equalTo(48)
		}
		// country
		scrollView.addSubview(countrySelectView)
		countrySelectView.snp.makeConstraints {
			$0.top.equalTo(emailTextField.snp.bottom)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
			$0.height.equalTo(48)
		}
		// country
		scrollView.addSubview(citySelectView)
		citySelectView.snp.makeConstraints {
			$0.top.equalTo(countrySelectView.snp.bottom)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
			$0.height.equalTo(48)
		}
		// loading view
		view.addSubview(loadingView)
		loadingView.hidesWhenStopped = true
		loadingView.snp.makeConstraints {
			$0.center.equalToSuperview()
		}
	}
	
	// MARK: - Show action sheet
	func showActionSheet(with titles: [String], completion: @escaping (String) -> Void) {
		let alertController = UIAlertController(title: nil,
												message: nil,
												preferredStyle: .actionSheet)
		alertController.view.tintColor = Colors.mainTextColor
		titles.forEach { title in
			let cityAction = UIAlertAction(title: title, style: .default, handler: { _ in
				completion(title)
				alertController.dismiss(animated: true)
			})
			alertController.addAction(cityAction)
		}
		let cancelAction = UIAlertAction(title: "alert.cancel".localized, style: .cancel, handler: { _ in
			alertController.dismiss(animated: true)
		})
		alertController.addAction(cancelAction)
		self.present(alertController, animated: true)
	}

	// MARK: - Text field delegate
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		self.view.endEditing(true)
		return false
	}
	
	// MARK: - Take photo from gallery
	func takePhotoFromGallery() {
		imagePicker.delegate = self
		imagePicker.sourceType = .savedPhotosAlbum
		imagePicker.allowsEditing = true
		
		present(imagePicker, animated: true)
	}
	
	func imagePickerController(_ picker: UIImagePickerController,
							   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let pickedImage = info[.editedImage] as? UIImage {
			avatarImageView.contentMode = .scaleAspectFill
			avatarImageView.image = pickedImage

			guard let jpegData = pickedImage.jpegData(compressionQuality: 0.5) else { return }
			let imgData = Data(jpegData)
			viewModel.editImageData = imgData

			let kbImageSize = Double(imgData.count) / 1000.0
			if kbImageSize >= 1000 {
				guard let jpegData = pickedImage.jpegData(compressionQuality: 0.25) else { return }
				let imgData = Data(jpegData)
				viewModel.editImageData = imgData
			}
		}
		self.dismiss(animated: true)
	}
}
