//
//  RecordTableViewCell.swift
//  SmartWallet
//
//  Created by Soheil on 05/04/2018.
//  Copyright © 2018 Soheil Novinfard. All rights reserved.
//

import UIKit

class RecordTableViewCell: UITableViewCell {

	@IBOutlet weak var amountLabel: UILabel!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var icon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		if UIScreen.main.nativeBounds.height == 1136 {
			amountLabel.font = amountLabel.font.withSize(17) // for others 20
			titleLabel.font = titleLabel.font.withSize(14) // for others 17
		}
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
