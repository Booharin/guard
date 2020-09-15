//
//  ConversationsListViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 15.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

protocol ConversationsListViewControllerProtocol: ViewControllerProtocol {
	var greetingLabel: UILabel { get }
    var greetingDescriptionLabel: UILabel { get }
	var tableView: UITableView { get }
	func updateTableView()
}

final class ConversationsListViewController<modelType: ViewModel>: UIViewController, UITableViewDelegate,
ConversationsListViewControllerProtocol where modelType.ViewType == ConversationsListViewControllerProtocol {

	var greetingLabel = UILabel()
    var greetingDescriptionLabel = UILabel()
	var tableView = UITableView()
	private var gradientView: UIView?
	var viewModel: modelType

	init(viewModel: modelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	var navController: UINavigationController? {
		self.navigationController
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		self.viewModel.assosiateView(self)
		view.backgroundColor = Colors.whiteColor
		addViews()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.isNavigationBarHidden = false
		self.navigationItem.setHidesBackButton(true, animated:false)
	}
	
	private func addViews() {
		// table view
		tableView.register(ConversationCell.self,
						   forCellReuseIdentifier: ConversationCell.reuseIdentifier)
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
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return createHeaderView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 105
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
	
	private func createHeaderView() -> UIView {
        let headerView = UIView()
        headerView.snp.makeConstraints {
            $0.height.equalTo(105)
            $0.width.equalTo(UIScreen.main.bounds.width)
        }
        headerView.addSubview(greetingLabel)
        greetingLabel.snp.makeConstraints {
            $0.height.equalTo(39)
            $0.width.equalTo(UIScreen.main.bounds.width)
            $0.top.equalToSuperview()
        }
        headerView.addSubview(greetingDescriptionLabel)
        greetingDescriptionLabel.snp.makeConstraints {
            $0.height.equalTo(28)
            $0.width.equalTo(UIScreen.main.bounds.width)
            $0.top.equalTo(greetingLabel.snp.bottom).offset(-2)
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
