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
}

class LawyersListViewController<modelType: ViewModel>: UIViewController, UITableViewDelegate,
LawyersListViewControllerProtocol where modelType.ViewType == LawyersListViewControllerProtocol {

	var filterButtonView = FilterButtonView()
    var viewModel: modelType

	var titleView = UIView()
	var titleLabel = UILabel()
	var tableView = UITableView()

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
	}
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if(velocity.y>0) {
            UIView.animate(withDuration: 0.3, animations: {
                self.navigationController?.setNavigationBarHidden(true, animated: true)
            })
            
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
            })
        }
    }
}
