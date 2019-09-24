//
//  RecordAddModel.swift
//  SmartWallet
//
//  Created by Soheil on 12/05/2018.
//  Copyright © 2018 Soheil Novinfard. All rights reserved.
//

import Foundation

class AddRecordModel {
	var amount: Double = 0
	var datetime = Date()
	var direction = 0
	var note: String?
	var reported: Bool?
	var uid: String?
	var expenseIndex = 0
	var incomeIndex = 0
	var accountIndex = 0
}
