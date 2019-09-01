//
//  Date+extensions.swift
//  SmartWallet
//
//  Created by Soheil on 08/06/2019.
//  Copyright © 2019 Soheil Novinfard. All rights reserved.
//

import Foundation

extension Date {
	static func randomDate(range: Int) -> Date {
		// Get the interval for the current date
		let interval =  Date().timeIntervalSince1970

		// There are 86,400 milliseconds in a day (ignoring leap dates)
		// Multiply the 86,400 milliseconds against the valid range of days
		let intervalRange = Double(86_400 * range)

		// Select a random point within the interval range
		let random = Double(arc4random_uniform(UInt32(intervalRange)) + 1)

		// Since this can either be in the past or future, we shift the range
		// so that the halfway point is the present
		let newInterval = interval + (random - (intervalRange / 2.0))
		// Initialize a date value with our newly created interval

		return Date(timeIntervalSince1970: newInterval)
	}

	static func monthsBetweenDates(
		startDate: Date?,
		endDate: Date?,
		currentDate: Date = Date()) -> [SWMonthDescription] {

		var mothYearData = [SWMonthDescription]()

		guard let startDate = startDate, let endDate = endDate else { return mothYearData }

		for year in startDate.year() ... endDate.year() {
			let monthStartIndex = year == startDate.year() ? startDate.month() : 1
			let monthEndIndex = year < endDate.year() ? 12 : endDate.month()

			for month in monthStartIndex ... monthEndIndex {
				let monthTitle = DateFormatter.monthFormatter.monthSymbols[month - 1]
				mothYearData.append(
					SWMonthDescription(
						year: year,
						month: month,
						title: monthTitle,
						currentYear: year == currentDate.year()
					)
				)
			}
		}

		return mothYearData
	}
}
