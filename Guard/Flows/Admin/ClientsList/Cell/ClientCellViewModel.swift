//
//  ClientCellViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 12.09.2021.
//  Copyright © 2021 ds. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit
import Alamofire

final class ClientCellViewModel:
    ViewModel,
    HasDependencies {

    typealias Dependencies =
        HasClientNetworkService &
        HasLocalStorageService
    lazy var di: Dependencies = DI.dependencies

    var view: ClientCellProtocol!

    var toClientSubject: PublishSubject<UserProfile>?
    private let clientImageSubject = PublishSubject<Any>()
    let tapSubject = PublishSubject<Any>()

    let animateDuration = 0.15
    let client: UserProfile
    private var disposeBag = DisposeBag()

    init(toClientSubject: PublishSubject<UserProfile>?,
         client: UserProfile) {
        self.toClientSubject = toClientSubject
        self.client = client
    }

    func viewDidSet() {
        view.containerView
            .rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                UIView.animate(withDuration: self.animateDuration, animations: {
                    self.view.containerView.backgroundColor = Colors.lightBlueColor
                }, completion: { _ in
                    UIView.animate(withDuration: self.animateDuration, animations: {
                        self.view.containerView.backgroundColor = .clear
                    })
                })
                self.toClientSubject?.onNext(self.client)
            }).disposed(by: disposeBag)

        view.avatarImageView.layer.cornerRadius = 21
        view.avatarImageView.clipsToBounds = true
        view.avatarImageView.layer.borderWidth = 1
        view.avatarImageView.layer.borderColor = Colors.lightGreyColor.cgColor

        if let image = di.localStorageService.getImage(with: "\(client.id)_profile_image.jpeg") {
            view.avatarImageView.image = image
        } else {
            view.avatarImageView.image = #imageLiteral(resourceName: "profile_icn").withRenderingMode(.alwaysTemplate)
            view.avatarImageView.tintColor = Colors.lightGreyColor
        }

        view.nameTitle.text = client.fullName.count <= 1 ? "chat.noName".localized : client.fullName
        view.nameTitle.font = SFUIDisplay.regular.of(size: 16)
        view.nameTitle.textColor = Colors.mainTextColor

        view.idLabel.font = SFUIDisplay.bold.of(size: 15)
        view.idLabel.textColor = Colors.mainTextColor
        view.idLabel.text = "\(String(client.id))"

        clientImageSubject
            .asObservable()
            .flatMap { [unowned self] _ in
                self.di.clientNetworkService.getPhoto(profileId: client.id)
            }
            .subscribe(onNext: { [weak self] result in
                switch result {
                    case .success(let data):
                        self?.view.avatarImageView.image = UIImage(data: data)
                        if let userID = self?.client.id {
                            self?.di.localStorageService.saveImage(data: data,
                                                                   name: "\(userID)_profile_image.jpeg")
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                }
            }).disposed(by: disposeBag)
        clientImageSubject.onNext(())
    }

    func removeBindings() {}
}

