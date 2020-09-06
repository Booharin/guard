//
//  LawyerListViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 03.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

protocol LawyerListViewControllerProtocol {
	var filterButtonView: FilterButtonView { get }
	var titleView: UIView { get }
	var titleLabel: UILabel { get }
}

class LawyerListViewController<modelType: ViewModel>: UIViewController,
LawyerListViewControllerProtocol where modelType.ViewType == LawyerListViewControllerProtocol {

	var filterButtonView = FilterButtonView()
    var viewModel: modelType

	var titleView = UIView()
	var titleLabel = UILabel()

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
		//self.navigationItem.titleView?.backgroundColor = .red
	}
	
	private func addViews() {
		titleView.addSubview(titleLabel)
		//titleLabel.backgroundColor = .green
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
	}
}
