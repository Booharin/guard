//
//  ClientAppealCellViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 09.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct ClientAppealCellViewModel: ViewModel {
    var view: ClientAppealCellProtocol!
    private var disposeBag = DisposeBag()
    let toAppealCreateSubject: PublishSubject<Any>
    let animateDuration = 0.15
    let clientAppeal: ClientAppeal

    init(clientAppeal: ClientAppeal, toAppealCreateSubject: PublishSubject<Any>) {
        self.clientAppeal = clientAppeal
        self.toAppealCreateSubject = toAppealCreateSubject
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
            self.toAppealCreateSubject.onNext(())
        }).disposed(by: disposeBag)
        
        view.appealImageView.image = #imageLiteral(resourceName: "car_accident_icn")

        view.titleLabel.text = clientAppeal.title
        view.titleLabel.font = SFUIDisplay.regular.of(size: 16)
        view.titleLabel.textColor = Colors.maintextColor
        
        view.descriptionLabel.font = SFUIDisplay.light.of(size: 12)
        view.descriptionLabel.textColor = Colors.subtitleColor
        view.descriptionLabel.text = clientAppeal.description
        view.dateLabel.text = ""
        view.timeLabel.text = ""
    }

    func removeBindings() {}
}
