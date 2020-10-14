//
//  AppealViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 14.10.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class AppealViewModel: ViewModel {
	var view: AppealViewControllerProtocol!
	private let animationDuration = 0.15
	private var disposeBag = DisposeBag()
    private let appeal: ClientAppeal
    
    init(appeal: ClientAppeal) {
        self.appeal = appeal
    }
	
	func viewDidSet() {
        view.titleLabel.font = SFUIDisplay.bold.of(size: 16)
        view.titleLabel.textColor = Colors.mainTextColor
        view.titleLabel.text = appeal.title
        view.titleLabel.textAlignment = .center
        
        view.issueTypeLabel.font = SFUIDisplay.medium.of(size: 15)
        view.issueTypeLabel.textColor = Colors.whiteColor
        view.issueTypeLabel.backgroundColor = Colors.warningColor
        view.issueTypeLabel.layer.cornerRadius = 12
        view.issueTypeLabel.clipsToBounds = true
        view.issueTypeLabel.text = appeal.issueType
        view.issueTypeLabel.textAlignment = .center
        
        view.issueDescriptionLabel.font = SFUIDisplay.regular.of(size: 16)
        view.issueDescriptionLabel.textColor = Colors.mainTextColor
        view.issueDescriptionLabel.text = appeal.appealDescription
        let textHeight = appeal.appealDescription.height(withConstrainedWidth: UIScreen.main.bounds.width - 72,
                                                         font: SFUIDisplay.regular.of(size: 16))
        view.issueDescriptionLabel.snp.updateConstraints {
            $0.height.equalTo(textHeight)
        }
        self.view.view.layoutIfNeeded()
        
        view.lawyerSelectedButton.setTitle("appeal.lawyerSelectedButton.title".localized.uppercased(),
                                           for: .normal)
        view.lawyerSelectedButton.backgroundColor = Colors.greenColor
        view.lawyerSelectedButton.layer.cornerRadius = 25
	}
	
	func removeBindings() {}
}
