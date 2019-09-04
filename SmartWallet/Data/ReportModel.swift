//
//  ReportModel.swift
//  SmartWallet
//
//  Created by Soheil on 04/09/2019.
//  Copyright © 2019 Soheil Novinfard. All rights reserved.
//

import Foundation

class ReportModel {

	// swiftlint:disable:next function_body_length
	static func monthlyOveralInfo() -> [SWMonthlyOverall] {
		let model = Facade.share.model

		let (minDate, maxDate) = model.getMinMaxDateInRecords()
		let monthYearList = Date.monthsBetweenDates(
			startDate: minDate,
			endDate: maxDate
		)
		let totalBudget = model.getTotalBudget()

		return monthYearList.compactMap {
			let numDays = Date.getMonthDuration(
				year: $0.year,
				month: $0.month,
				considerCurrent: true
			)
			let numDaysAll = Date.getMonthDuration(
				year: $0.year,
				month: $0.month,
				considerCurrent: false
			)

			let monthlyTotalCost = model.getTotalMonth(
				year: $0.year,
				month: $0.month,
				type: .cost
			)
			let dailyAverageCost = monthlyTotalCost / Double(numDays)

			let monthlyTotalIncome = model.getTotalMonth(
				year: $0.year,
				month: $0.month,
				type: .income
			)
			let dailyAverageIncome = monthlyTotalIncome / Double(numDays)

			let monthlyTotal = monthlyTotalIncome - monthlyTotalCost
			let dailyAverage = dailyAverageIncome - dailyAverageCost

			var items = [SWMonthlyItem]()

			items.append(SWMonthlyItem(
				type: .totalCost,
				value: monthlyTotalCost,
				recordType: .cost
			))

			items.append(SWMonthlyItem(
				type: .totalIncome,
				value: monthlyTotalIncome,
				recordType: .income
			))

			items.append(SWMonthlyItem(
				type: .total,
				value: monthlyTotal,
				recordType: .all
			))

			if totalBudget > 0 {
				let monthlyTotalSave = totalBudget - monthlyTotalCost
				items.append(SWMonthlyItem(
					type: .totalSave,
					value: monthlyTotalSave,
					recordType: .all
				))
			}

			items.append(SWMonthlyItem(
				type: .dailyAverage,
				value: dailyAverage,
				recordType: .all
			))

			items.append(SWMonthlyItem(
				type: .dailyAverageCost,
				value: dailyAverageCost,
				recordType: .cost
			))

			items.append(SWMonthlyItem(
				type: .dailyAverageIncome,
				value: dailyAverageIncome,
				recordType: .income
			))

			let monthlyForecast = dailyAverage * Double(numDaysAll)
			items.append(SWMonthlyItem(
				type: .forcast,
				value: monthlyForecast,
				recordType: .all
			))

			let monthlyForecastCost = dailyAverageCost * Double(numDaysAll)
			items.append(SWMonthlyItem(
				type: .forcastCost,
				value: monthlyForecastCost,
				recordType: .cost
			))

			let monthlyForecastIncome = dailyAverageIncome * Double(numDaysAll)
			items.append(SWMonthlyItem(
				type: .forcastIncome,
				value: monthlyForecastIncome,
				recordType: .income
			))

			return SWMonthlyOverall(month: $0, items: items)
		}
	}
}

struct SWMonthlyOverall {
	let month: SWMonth
	var items: [SWMonthlyItem]
}

struct SWMonthlyItem {
	let type: SWMonthlyOverallType
	let value: Double
	let recordType: RecordType

	var label: String {
		return value.recordPresenter(for: recordType)
	}
}

enum SWMonthlyOverallType: String {
	case totalCost = "Total Cost"
	case totalIncome = "Total Income"
	case total = "Total"
	case totalSave = "Total Save"
	case dailyAverage = "Daily Average"
	case dailyAverageCost = "Daily Average Cost"
	case dailyAverageIncome = "Daily Average Income"
	case forcast = "Monthly Forecast"
	case forcastCost = "Monthly Forecast Cost"
	case forcastIncome = "Monthly Forecast Income"
}
