//
//  SWMonthDescription.swift
//  SmartWallet
//
//  Created by Soheil on 01/09/2019.
//  Copyright © 2019 Soheil Novinfard. All rights reserved.
//

import Foundation

struct SWMonthDescription {
	let year: Int
	let month: Int
	let title: String
	let currentYear: Bool

	var titleWithYear: String {
		return "\(title) \(year)"
	}

	var titleWithCurrentYear: String {
		return currentYear ? title : titleWithYear
	}
}
