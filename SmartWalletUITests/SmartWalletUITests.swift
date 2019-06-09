//
//  SmartWalletUITests.swift
//  SmartWalletUITests
//
//  Created by Soheil on 02/06/2019.
//  Copyright © 2019 Soheil Novinfard. All rights reserved.
//

import XCTest
@testable import SmartWallet

class SmartWalletUITests: XCTestCase {

    override func setUp() {
		super.setUp()
		continueAfterFailure = false

		let app = XCUIApplication()
		setupSnapshot(app)
		app.launch()
    }

    override func tearDown() {
		super.tearDown()
	}

    func testTakingSnapshot() {
		let app = XCUIApplication()
		sleep(30)

		let startButton = app.buttons["Start Now!"]
		if startButton.exists {
			snapshot("1- Splash", timeWaitingForIdle: 10)
			startButton.tap()
		}

		snapshot("3- Records", timeWaitingForIdle: 10)
		app.tables.cells.element(boundBy: 0).tap()
		app.buttons["Edit"].tap()
		snapshot("2- Add Edit Record", timeWaitingForIdle: 10)
		app.navigationBars["Add Record"].buttons["Record"].tap()
		app.navigationBars["Record"].buttons["Records"].tap()

		let tabBarsQuery = app.tabBars

		tabBarsQuery.buttons["Budget"].tap()
		snapshot("4- Budget", timeWaitingForIdle: 10)

		tabBarsQuery.buttons["Settings"].tap()

		let tablesQuery = app.tables
		tablesQuery.staticTexts["Categories"].tap()
		snapshot("7- Categories", timeWaitingForIdle: 10)

		app.navigationBars["Categories"].buttons["Settings"].tap()

		tabBarsQuery.buttons["Dashboard"].tap()
		snapshot("5- Dashboard", timeWaitingForIdle: 10)

		app.swipeUp()
		snapshot("6- Dashboard Bottom", timeWaitingForIdle: 10)
    }
}
