//
//  ChatViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 14.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

protocol ChatViewControllerProtocol: ViewControllerProtocol {
	var backButtonView: BackButtonView { get }
	var appealButtonView: AppealButtonView { get }
	var titleView: UIView { get }
	var titleLabel: UILabel { get }
	var tableView: UITableView { get }
	var chatBarView: ChatBarViewProtocol { get }
	var loadingView: LottieAnimationView { get }
	func takePhotoFromGallery()
}

final class ChatViewController<modelType: ChatViewModel>:
	UIViewController,
	UITableViewDelegate,
	UIImagePickerControllerDelegate,
	UINavigationControllerDelegate,
	ChatViewControllerProtocol {

	var backButtonView = BackButtonView()
	var appealButtonView = AppealButtonView()
	var titleView = UIView()
	var titleLabel = UILabel()
	var chatBarView: ChatBarViewProtocol = ChatBarView()
	var tableView = UITableView()
	private var gradientView: UIView?
	var navController: UINavigationController? {
		self.navigationController
	}
	var viewModel: modelType
	var loadingView = LottieAnimationView()
	private var imagePicker = UIImagePickerController()

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

		viewModel.messagesListSubject?.onNext(())
	}

	private func setNavigationBar() {
		let leftBarButtonItem = UIBarButtonItem(customView: backButtonView)
		self.navigationItem.leftBarButtonItem = leftBarButtonItem
		let rightBarButtonItem = UIBarButtonItem(customView: appealButtonView)
		self.navigationItem.rightBarButtonItem = rightBarButtonItem
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

		// chat bar
		view.addSubview(chatBarView)
		chatBarView.snp.makeConstraints {
			$0.leading.trailing.equalToSuperview()
			$0.bottom.equalToSuperview()
			$0.height.equalTo(106)
		}

		// table view
		tableView.tableFooterView = UIView()
		tableView.backgroundColor = Colors.whiteColor
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 80
		tableView.separatorStyle = .none
		tableView.delegate = self
		tableView.contentInset = UIEdgeInsets(top: 30,
											  left: 0,
											  bottom: 20,
											  right: 0)
		view.addSubview(tableView)
		tableView.snp.makeConstraints {
			$0.leading.trailing.equalToSuperview()
			$0.top.equalToSuperview().offset(10)
			$0.bottom.equalTo(chatBarView.snp.top)
		}
		// loading view
		view.addSubview(loadingView)
		loadingView.snp.makeConstraints {
			$0.center.equalToSuperview()
			$0.width.height.equalTo(300)
		}
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerView = UIView()
		headerView.snp.makeConstraints {
			$0.height.equalTo(40)
			$0.width.equalTo(UIScreen.main.bounds.width)
		}
		return headerView
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 40
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

			guard let jpegData = pickedImage.jpegData(compressionQuality: 0.5) else { return }
			let imgData = Data(jpegData)
			viewModel.imageForSending = imgData

			let kbImageSize = Double(imgData.count) / 1000.0
			if kbImageSize >= 1000 {
				guard let jpegData = pickedImage.jpegData(compressionQuality: 0.25) else { return }
				let imgData = Data(jpegData)
				viewModel.imageForSending = imgData
			}
		}
		self.dismiss(animated: true)
	}
}
