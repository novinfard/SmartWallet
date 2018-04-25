//
//  BudgetTableViewCell.swift
//  SmartWallet
//
//  Created by Soheil on 25/04/2018.
//  Copyright © 2018 Soheil Novinfard. All rights reserved.
//

import UIKit

class BudgetTableViewCell: UITableViewCell, UITextFieldDelegate {

	@IBOutlet weak var categoryLabel: UILabel!
	@IBOutlet weak var budgetAmount: UITextField!
	@IBOutlet weak var amountLabel: UILabel!
	@IBOutlet weak var budgetPercentage: UIProgressView!
	
	override func awakeFromNib() {
        super.awakeFromNib()
		
		amountLabel.text = getCurrencyLabel()
		budgetAmount.delegate = self
		
		let bgColorView = UIView()
		bgColorView.backgroundColor = UIColor.myAppLightGreen
		self.selectedBackgroundView = bgColorView
    }
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		setSelected(true, animated: true)
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		setSelected(false, animated: true)
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
		
        // Configure the view for the selected state
    }
	
	func makeFirstResponder() {
		budgetAmount.becomeFirstResponder()
	}

}
