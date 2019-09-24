//
//  DateTests.swift
//  SmartWalletTests
//
//  Created by Soheil on 01/09/2019.
//  Copyright © 2019 Soheil Novinfard. All rights reserved.
//

import XCTest
@testable import SmartWallet

class DateTests: XCTestCase {

    func testMonthBetweenDates() {
		let startDate = DateFormatter.fullDateFormatter.date(from: "2018-03-10")!
		let endDate = DateFormatter.fullDateFormatter.date(from: "2019-11-20")!
		let currentDate = DateFormatter.fullDateFormatter.date(from: "2019-11-25")!
        let sut = Date.monthsBetweenDates(
			startDate: startDate,
			endDate: endDate,
			currentDate: currentDate
		)

		XCTAssertEqual(sut.count, 21, "The number of months between dates are wrong")

		let firstMonth = sut.first!
		XCTAssertEqual(firstMonth.year, 2018, "The year of first month is wrong")
		XCTAssertEqual(firstMonth.month, 3, "The month of first month is wrong")
		XCTAssertEqual(firstMonth.title, "March", "Th title of first month is wrong")
		XCTAssertEqual(firstMonth.currentYear, false, "The currentYear of of first month is wrong")
		XCTAssertEqual(firstMonth.titleWithYear, "March 2018", "The titleWithYear of first month is wrong")
		XCTAssertTrue(
			firstMonth.titleWithCurrentYear == firstMonth.titleWithYear,
			"For non-current year the titles (titleWithCurrentYear and titleWithYear) should be the same"
		)

		let lastMonth =  sut.last!
		XCTAssertEqual(lastMonth.year, 2019, "The year of last month is wrong")
		XCTAssertEqual(lastMonth.currentYear, true, "The currentYear of last month is wrong")
		XCTAssertEqual(lastMonth.titleWithYear, "November 2019", "The titleWithYear of last month is wrong")
		XCTAssertTrue(
			lastMonth.titleWithCurrentYear != lastMonth.titleWithYear,
			"For current year the titles (titleWithCurrentYear and titleWithYear) should be different"
		)

    }

}
