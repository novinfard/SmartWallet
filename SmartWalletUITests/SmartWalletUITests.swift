//
//  SmartWalletUITests.swift
//  SmartWalletUITests
//
//  Created by Soheil on 02/06/2019.
//  Copyright © 2019 Soheil Novinfard. All rights reserved.
//

import XCTest

class SmartWalletUITests: XCTestCase {

    override func setUp() {
		let app = XCUIApplication()
		setupSnapshot(app)
		app.launch()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

}
