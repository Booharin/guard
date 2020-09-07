//
//  LawyerCellViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 07.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import RxSwift
import RxCocoa

struct LawyerCellViewModel: ViewModel {
	var view: LawyerCellProtocol!
	private var disposeBag = DisposeBag()
	let toLawyerSubject: PublishSubject<UserProfile>
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
				self.toLawyerSubject.onNext(self.lawyer)
			}).disposed(by: disposeBag)
		
		view.nameTitle.text = lawyer.fullName
		view.nameTitle.font = SFUIDisplay.regular.of(size: 16)
		view.nameTitle.textColor = Colors.maintextColor
	}
	
	func removeBindings() {}
}
