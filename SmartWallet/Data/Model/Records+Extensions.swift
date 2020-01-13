//
//  Records+Extensions.swift
//  SmartWallet
//
//  Created by Soheil on 12/01/2020.
//  Copyright © 2020 Soheil Novinfard. All rights reserved.
//

import Foundation

enum DirectionType {
	case cost
	case income
}

extension Records {
	var directionType: DirectionType {
		if self.direction == -1 {
			return .cost
		} else {
			return .income
		}
	}
}

extension Sequence where Element: Records {

	func sum() -> SWRecordRepresentation {
		let costs = self.sumAmount(type: .cost)
		let incomes = self.sumAmount(type: .income)

		let total = incomes - costs

		return SWRecordRepresentation(
			type: .total,
			value: total,
			recordType: .all
		)
	}

	func sumAmount(type: DirectionType) -> Double {
		return self.filter({ $0.directionType == type })
		.map({ record in record.amount})
		.reduce(0, +)
	}
}
