//
//  ViewModel.swift
//  Guard
//
//  Created by Alexandr Bukharin on 11.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Foundation

protocol ViewModel {
    associatedtype ViewType
    mutating func assosiateView(_ view:  ViewType?)
    func viewDidSet()
    func removeBindings()
    
    var view: ViewType! {get set}
}

extension ViewModel {
    mutating func assosiateView(_ view:  ViewType?) {
        guard let view = view else {
            removeBindings()
            return
        }
        removeBindings()
        self.view = view
        viewDidSet()
    }
}
