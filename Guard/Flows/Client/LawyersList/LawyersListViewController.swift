//
//  LawyersListViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 03.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

protocol LawyersListViewControllerProtocol {
	var filterButtonView: FilterButtonView { get }
	var titleView: UIView { get }
	var titleLabel: UILabel { get }
	var tableView: UITableView { get }
	var loadingView: UIActivityIndicatorView { get }
	func showActionSheet(with cities: [String])
}

final class LawyersListViewController<modelType: LawyersListViewModel>:
	UIViewController,
	UITableViewDelegate,
	LawyersListViewControllerProtocol {

	var filterButtonView = FilterButtonView()
	var viewModel: modelType

	var titleView = UIView()
	var titleLabel = UILabel()
	var tableView = UITableView()
	var loadingView = UIActivityIndicatorView(style: .medium)
	private var gradientView: UIView?

	private var lawyers: [UserProfile]?

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
		let rightBarButtonItem = UIBarButtonItem(customView: filterButtonView)
		self.navigationItem.rightBarButtonItem = rightBarButtonItem
		self.navigationItem.titleView = titleView
	}

	private func addViews() {
		// title view
		titleView.addSubview(titleLabel)
		titleLabel.snp.makeConstraints {
			$0.center.equalToSuperview()
			$0.width.lessThanOrEqualTo(200)
		}

		titleView.snp.makeConstraints {
			$0.width.equalTo(titleLabel.snp.width).offset(46)
			$0.height.equalTo(40)
		}

		let locationImageView = UIImageView(image: #imageLiteral(resourceName: "location_marker_icn").withRenderingMode(.alwaysTemplate))
		locationImageView.tintColor = Colors.mainColor
		titleView.addSubview(locationImageView)
		locationImageView.snp.makeConstraints {
			$0.width.height.equalTo(20)
			$0.centerY.equalToSuperview()
			$0.trailing.equalTo(titleLabel.snp.leading).offset(-3)
		}
		
		let chevronImageView = UIImageView(image: #imageLiteral(resourceName: "location_chevron_down").withRenderingMode(.alwaysTemplate))
		chevronImageView.tintColor = Colors.mainColor
		titleView.addSubview(chevronImageView)
		chevronImageView.snp.makeConstraints {
			$0.width.height.equalTo(6)
			$0.centerY.equalToSuperview()
			$0.leading.equalTo(titleLabel.snp.trailing).offset(3)
		}
		
		// table view
		tableView.register(SelectIssueTableViewCell.self,
						   forCellReuseIdentifier: SelectIssueTableViewCell.reuseIdentifier)
		tableView.tableFooterView = UIView()
		tableView.backgroundColor = Colors.whiteColor
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 72
		tableView.separatorStyle = .none
		tableView.delegate = self
		view.addSubview(tableView)
		tableView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
		// loading view
		view.addSubview(loadingView)
		loadingView.hidesWhenStopped = true
		loadingView.snp.makeConstraints {
			$0.center.equalToSuperview()
		}
	}
	
	func scrollViewWillEndDragging(_ scrollView: UIScrollView,
								   withVelocity velocity: CGPoint,
								   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		
		if(velocity.y > 0) {
			// add gradient view
			gradientView = createGradentView()
			guard let gradientView = gradientView else { return }
			view.addSubview(gradientView)
			gradientView.snp.makeConstraints {
				$0.top.leading.trailing.equalToSuperview()
				$0.height.equalTo(50)
			}
			// hide nav bar
			UIView.animate(withDuration: 0.3, animations: {
				self.navigationController?.setNavigationBarHidden(true, animated: true)
			})
		} else {
			// remove gradient view
			gradientView?.removeFromSuperview()
			gradientView = nil
			// remove nav bar
			UIView.animate(withDuration: 0.3, animations: {
				self.navigationController?.setNavigationBarHidden(false, animated: true)
			})
		}
	}
	
	private func createGradentView() -> UIView {
		let gradientLAyer = CAGradientLayer()
		gradientLAyer.colors = [
			Colors.whiteColor.cgColor,
			Colors.whiteColor.withAlphaComponent(0).cgColor
		]
		gradientLAyer.locations = [0.0, 1.0]
		gradientLAyer.frame = CGRect(x: 0,
									 y: 0,
									 width: UIScreen.main.bounds.width, height: 50)
		let view = UIView()
		view.layer.insertSublayer(gradientLAyer, at: 0)
		return view
	}
	
	// MARK: - Show cities action sheet
	func showActionSheet(with cities: [String]) {
		let alertController = UIAlertController(title: nil,
												message: nil,
												preferredStyle: .actionSheet)
		alertController.view.tintColor = Colors.mainTextColor
		cities.forEach { city in
			let cityAction = UIAlertAction(title: city, style: .default, handler: { _ in
				self.titleLabel.text = city
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
}
