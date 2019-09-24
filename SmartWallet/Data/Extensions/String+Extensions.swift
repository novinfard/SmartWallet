//
//  String+Extensions.swift
//  SmartWallet
//
//  Created by Soheil on 03/09/2019.
//  Copyright © 2019 Soheil Novinfard. All rights reserved.
//

import Foundation

extension String {
	func getDoubleFromLocal() -> Double {
		var value = 0.0
		let numberFormatter = NumberFormatter()
		let decimalFiltered = self.replacingOccurrences(of: "٫|,", with: ".", options: .regularExpression)
		numberFormatter.locale = Locale(identifier: "EN")
		if let amountValue = numberFormatter.number(from: decimalFiltered) {
			value = amountValue.doubleValue
		}
		return value
	}
}
