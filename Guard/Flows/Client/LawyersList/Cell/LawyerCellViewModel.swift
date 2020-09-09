//
//  LawyerCellViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 07.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

struct LawyerCellViewModel: ViewModel {
	var view: LawyerCellProtocol!
	private var disposeBag = DisposeBag()
	let toLawyerSubject: PublishSubject<UserProfile>
    let animateDuration = 0.15
	let lawyer: UserProfile

	init(toLawyerSubject: PublishSubject<UserProfile>,
		 lawyer: UserProfile) {
		self.toLawyerSubject = toLawyerSubject
		self.lawyer = lawyer
	}
	
	func viewDidSet() {
		view.containerView
			.rx
			.tapGesture()
			.skip(1)
			.subscribe(onNext: { _ in
                UIView.animate(withDuration: self.animateDuration, animations: {
                    self.view.containerView.backgroundColor = Colors.cellSelectedColor
                }, completion: { _ in
                    UIView.animate(withDuration: self.animateDuration, animations: {
                        self.view.containerView.backgroundColor = .clear
                    })
                })
				self.toLawyerSubject.onNext(self.lawyer)
			}).disposed(by: disposeBag)
        
        view.avatarImageView.image = #imageLiteral(resourceName: "lawyer_mock_icn")
		
		view.nameTitle.text = lawyer.fullName
		view.nameTitle.font = SFUIDisplay.regular.of(size: 16)
		view.nameTitle.textColor = Colors.maintextColor
        
        view.rateLabel.font = SFUIDisplay.bold.of(size: 15)
        view.rateLabel.textColor = Colors.maintextColor
        view.rateLabel.text = "\(String(format: "%.1f", lawyer.rate))"
	}
	
	func removeBindings() {}
}
