//
//  SWMonthDescription.swift
//  SmartWallet
//
//  Created by Soheil on 01/09/2019.
//  Copyright © 2019 Soheil Novinfard. All rights reserved.
//

import Foundation

struct SWMonth {
	let year: Int
	let shortYear: Int
	let month: Int
	let title: String
	let shortTitle: String
	let currentYear: Bool

	var titleWithYear: String {
		return "\(title) \(year)"
	}

	var shortTitleWithYear: String {
		return "\(shortTitle) \(shortYear)"
	}

	var titleWithCurrentYear: String {
		return currentYear ? title : titleWithYear
	}

	var shortTitleWithCurrentYear: String {
		return currentYear ? shortTitle : shortTitleWithYear
	}
}
