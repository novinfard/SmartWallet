//
//  Categories+Extensions.swift
//  SmartWallet
//
//  Created by Soheil on 05/01/2020.
//  Copyright © 2020 Soheil Novinfard. All rights reserved.
//

import CoreData
import UIKit

extension Categories {
	var iconImage: UIImage? {
		let defaultIcon = self.direction > 0 ? "UpIcon" : "DownIcon"
		let iconName = self.icon.isEmpty ? defaultIcon : self.icon
		return UIImage(named: iconName)
	}
}
