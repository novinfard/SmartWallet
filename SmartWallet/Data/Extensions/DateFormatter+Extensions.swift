//
//  DateFormatter+Extensions.swift
//  SmartWallet
//
//  Created by Soheil on 01/09/2019.
//  Copyright © 2019 Soheil Novinfard. All rights reserved.
//

import Foundation

extension DateFormatter {
	static let monthFormatter: DateFormatter = {
		let dateFormtter = DateFormatter()
		dateFormtter.dateFormat = "MM"

		return dateFormtter
	}()
}
