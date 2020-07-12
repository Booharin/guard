//
//  RegistrationViewController.swift
//  Guard
//
//  Created by Alexandr Bukharin on 11.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
/// Controller for registration screen
class RegistrationViewController: UIViewController {
	/// Pass to main screen
	var toMain: (() -> (Void))?

    override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = Colors.authBackground
		addViews()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		setNavigationBar()
	}
	
	private func setNavigationBar() {
		navigationController?.isNavigationBarHidden = false
        self.navigationItem.setHidesBackButton(true, animated:false)
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 24))
        let imageView = UIImageView(frame: CGRect(x: 9, y: 0, width: 35, height: 24))
        
		imageView.image = #imageLiteral(resourceName: "icn_back_arrow").withRenderingMode(.alwaysTemplate)
		imageView.tintColor = Colors.borderColor
        view.addSubview(imageView)
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(back))
        view.addGestureRecognizer(backTap)
        let leftBarButtonItem = UIBarButtonItem(customView: view)
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    @objc private func back() {
		self.navigationController?.popViewController(animated: true)
    }

	private func addViews() {
		
	}
}
