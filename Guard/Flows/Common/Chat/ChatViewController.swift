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
	var loadingView: UIActivityIndicatorView { get }
}

final class ChatViewController<modelType: ChatViewModel>:
	UIViewController,
	UITableViewDelegate,
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
	var loadingView = UIActivityIndicatorView(style: .medium)

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

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
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
		tableView.register(SelectIssueTableViewCell.self,
						   forCellReuseIdentifier: SelectIssueTableViewCell.reuseIdentifier)
		tableView.tableFooterView = UIView()
		tableView.backgroundColor = Colors.whiteColor
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 80
		tableView.separatorStyle = .none
		tableView.delegate = self
		view.addSubview(tableView)
		tableView.snp.makeConstraints {
			$0.leading.trailing.equalToSuperview()
			$0.top.equalToSuperview().offset(10)
			$0.bottom.equalTo(chatBarView.snp.top)
		}
		// loading view
		view.addSubview(loadingView)
		loadingView.hidesWhenStopped = true
		loadingView.snp.makeConstraints {
			$0.center.equalToSuperview()
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
}
