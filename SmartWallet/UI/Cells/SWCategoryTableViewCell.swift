//
//  SWCategoryTableViewCell.swift
//  SmartWallet
//
//  Created by Soheil on 16/01/2020.
//  Copyright © 2020 Soheil Novinfard. All rights reserved.
//

import UIKit

struct SWCategoryTableViewCellModel {
	let title: String?
	let icon: UIImage?
}

class SWCategoryTableViewCell: UITableViewCell {
	@IBOutlet private var iconView: UIImageView?
	@IBOutlet private var titleLabel: UILabel?

	func setup(model: SWCategoryTableViewCellModel) {
		self.titleLabel?.text = model.title
		self.iconView?.image = model.icon
	}
}
