//
//  FilterScreenViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 01.04.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import UIKit

protocol FilterScreenViewControllerProtocol: class, ViewControllerProtocol {
	var searchButton: UIButton { get }
	var closeButton: UIButton { get }
	var titleLabel: UILabel { get }
	var tableView: UITableView { get }
	var loadingView: LottieAnimationView { get }
	var searchTextField: SearchTextField { get }
}

final class FilterScreenViewController<modelType: FilterScreenViewModel>:
	UIViewController,
	UITableViewDelegate,
	FilterScreenViewControllerProtocol {

	var searchButton = UIButton()
	var closeButton = UIButton()
	var titleLabel = UILabel()
	var tableView = UITableView()
	var loadingView = LottieAnimationView()
	var searchTextField = SearchTextField(placeHolderTitle: "filter.search.placeholder.title".localized)

	private var gradientView: UIView?
	private let gradientViewHeight = 100

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
	}

	private func addViews() {
		addGradientView()

		// table view
		tableView.register(FilterIssuesCell.self,
						   forCellReuseIdentifier: FilterIssuesCell.reuseIdentifier)
		tableView.tableFooterView = UIView()
		tableView.backgroundColor = Colors.whiteColor
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 72
		tableView.separatorStyle = .none
		tableView.delegate = self
		view.addSubview(tableView)
		tableView.snp.makeConstraints {
			if let gradientView = gradientView {
				$0.top.equalTo(gradientView.snp.bottom)
			}
			$0.leading.trailing.bottom.equalToSuperview()
		}

		// loading view
		view.addSubview(loadingView)
		loadingView.snp.makeConstraints {
			$0.center.equalToSuperview()
			$0.width.height.equalTo(300)
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
									 width: UIScreen.main.bounds.width,
									 height: 100)
		let view = UIView()
		view.layer.insertSublayer(gradientLAyer, at: 0)
		return view
	}

	private func addGradientView() {
		gradientView = createGradentView()
		guard let gradientView = gradientView else { return }
		view.addSubview(gradientView)
		gradientView.snp.makeConstraints {
			$0.top.equalToSuperview().offset(20)
			$0.leading.trailing.equalToSuperview()
			$0.height.equalTo(gradientViewHeight)
		}

		gradientView.addSubview(titleLabel)
		titleLabel.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.leading.trailing.equalToSuperview().inset(73)
		}

		gradientView.addSubview(searchTextField)
		searchTextField.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.leading.trailing.equalToSuperview().inset(71)
			$0.height.equalTo(33)
		}

		gradientView.addSubview(searchButton)
		searchButton.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.leading.equalToSuperview().inset(13)
			$0.width.height.equalTo(60)
		}

		gradientView.addSubview(closeButton)
		closeButton.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.trailing.equalToSuperview().inset(13)
			$0.width.height.equalTo(60)
		}
	}
}
