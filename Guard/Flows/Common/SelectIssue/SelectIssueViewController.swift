//
//  SelectIssueViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 19.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
/// Protocol of controller for selecting client issue
protocol SelectIssueViewControllerProtocol: class, ViewControllerProtocol {
	var tableView: UITableView { get }
	var backButtonView: BackButtonView { get }
	var titleView: UIView { get }
	var titleLabel: UILabel { get }
	var headerTitleLabel: UILabel { get }
	var headerSubtitleLabel: UILabel { get }
	func updateTableView()
}

/// Controller for selecting client issue
final class SelectIssueViewController<modelType: SelectIssueViewModel>: UIViewController, UITableViewDelegate, SelectIssueViewControllerProtocol {
	
	var tableView = UITableView()
	var backButtonView = BackButtonView()
	var titleView = UIView()
	var titleLabel = UILabel()
	var headerTitleLabel = UILabel()
	var headerSubtitleLabel = UILabel()
	var navController: UINavigationController? {
		return self.navigationController
	}
	var viewModel: SelectIssueViewModel
	private var gradientView: UIView?
	private var issues: [String]?
	
	private var isToMain: Bool {
		if viewModel.toMainSubject == nil {
			return false
		} else {
			return true
		}
	}
	
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
		addViews()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.isNavigationBarHidden = false
		self.navigationItem.setHidesBackButton(true, animated: false)
		
		if isToMain {
			
		} else {
			let leftBarButtonItem = UIBarButtonItem(customView: backButtonView)
			self.navigationItem.leftBarButtonItem = leftBarButtonItem
			
			self.navigationItem.titleView = titleView
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if !isToMain {
			navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
		}
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
		// table view
		tableView.register(SelectIssueTableViewCell.self,
						   forCellReuseIdentifier: SelectIssueTableViewCell.reuseIdentifier)
		tableView.tableFooterView = UIView()
		tableView.backgroundColor = Colors.whiteColor
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 82
		tableView.separatorStyle = .none
		tableView.delegate = self
		view.addSubview(tableView)
		tableView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if isToMain {
			return createToMainHeaderView()
		} else {
			return createAppealHeaderView()
		}
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return viewModel.headerSubtitleHeight
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
	
	private func createAppealHeaderView() -> UIView {
		let headerView = UIView()
		headerView.snp.makeConstraints {
			$0.height.equalTo(viewModel.headerSubtitleHeight)
			$0.width.equalTo(UIScreen.main.bounds.width)
		}
		headerView.addSubview(headerTitleLabel)
		headerTitleLabel.snp.makeConstraints {
			$0.height.equalTo(24)
			$0.width.equalTo(UIScreen.main.bounds.width)
			$0.top.equalToSuperview().offset(4)
		}
		headerView.addSubview(headerSubtitleLabel)
		headerSubtitleLabel.snp.makeConstraints {
			$0.top.equalTo(headerTitleLabel.snp.bottom)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
			$0.bottom.equalToSuperview().offset(-30)
		}
		return headerView
	}
	
	private func createToMainHeaderView() -> UIView {
		let headerView = UIView()
		headerView.snp.makeConstraints {
			$0.height.equalTo(95)
			$0.width.equalTo(UIScreen.main.bounds.width)
		}
		headerView.addSubview(headerTitleLabel)
		headerTitleLabel.snp.makeConstraints {
			$0.height.equalTo(39)
			$0.width.equalTo(UIScreen.main.bounds.width)
			$0.top.equalToSuperview()
		}
		headerView.addSubview(headerSubtitleLabel)
		headerSubtitleLabel.snp.makeConstraints {
			$0.height.equalTo(28)
			$0.width.equalTo(UIScreen.main.bounds.width)
			$0.top.equalTo(headerTitleLabel.snp.bottom).offset(-2)
		}
		return headerView
	}
	
	func updateTableView() {
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
		
		if tableView.contentSize.height <= tableView.frame.height {
			tableView.isScrollEnabled = false
		} else {
			tableView.isScrollEnabled = true
		}
	}
}
