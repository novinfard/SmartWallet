//
//  NSLocale+Extensions.swift
//  SmartWallet
//
//  Created by Soheil on 03/09/2019.
//  Copyright © 2019 Soheil Novinfard. All rights reserved.
//

import Foundation

extension NSLocale {
	static var defaultCurrency: String {
		return UserDefaults.standard.string(forKey: "currencySymbol") ?? ""
	}
}
