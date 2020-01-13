//
//  SWRecordHeaderView.swift
//  SmartWallet
//
//  Created by Soheil on 12/01/2020.
//  Copyright © 2020 Soheil Novinfard. All rights reserved.
//

import UIKit

struct SWRecordHeaderViewModel {
	let title: String?
	let spending: String?
}

class SWRecordHeaderView: SWCustomView {
	@IBOutlet private var titleLabel: UILabel?
	@IBOutlet private var spendingLabel: UILabel?

	override func initUI() {
		self.titleLabel?.font = self.titleLabel?.font.withSize(17)
		self.spendingLabel?.font = self.spendingLabel?.font.withSize(15)
		self.spendingLabel?.textColor = .gray
	}

	func setup(with viewModel: SWRecordHeaderViewModel) {
		self.titleLabel?.text = viewModel.title
		self.spendingLabel?.text = viewModel.spending
	}
}
