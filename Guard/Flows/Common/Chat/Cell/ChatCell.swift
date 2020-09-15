//
//  ChatCell.swift
//  Guard
//
//  Created by Alexandr Bukharin on 15.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit

protocol ChatCellProtocol {
	var containerView: UIView { get }
}

final class ChatCell: UITableViewCell, ChatCellProtocol {
	var containerView = UIView()
	var viewModel: ChatCellViewModel!
}
