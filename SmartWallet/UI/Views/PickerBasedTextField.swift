//
//  PickerBasedTextField.swift
//  SmartWallet
//
//  Created by Soheil on 11/04/2018.
//  Copyright © 2018 Soheil Novinfard. All rights reserved.
//

import UIKit

class PickerBasedTextField: UITextField, UITextFieldDelegate {

	override func caretRect(for position: UITextPosition) -> CGRect {
		return CGRect.zero
	}

	let border = CALayer()
	let width = CGFloat(2.0)

	required init?(coder aDecoder: (NSCoder?)) {
		super.init(coder: aDecoder!)
		self.delegate=self
		border.borderColor = UIColor.black.cgColor
		border.frame = CGRect(
			x: 0,
			y: self.frame.size.height - width,
			width: self.frame.size.width,
			height: self.frame.size.height)
		border.borderWidth = width
		self.layer.addSublayer(border)
		self.layer.masksToBounds = true
	}

	override func draw(_ rect: CGRect) {
		border.frame = CGRect(
			x: 0,
			y: self.frame.size.height - width,
			width: self.frame.size.width,
			height: self.frame.size.height)
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		border.frame = CGRect(
			x: 0,
			y: self.frame.size.height - width,
			width: self.frame.size.width,
			height: self.frame.size.height)
	}
}
