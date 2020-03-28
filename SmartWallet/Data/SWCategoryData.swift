//
//  SWCategoryData.swift
//  SmartWallet
//
//  Created by Soheil on 27/03/2020.
//  Copyright © 2020 Soheil Novinfard. All rights reserved.
//

import Foundation

enum SWCategoryType {
	case expense
	case income

	var direction: Int {
		switch self {
		case .expense:
			return -1
		case .income:
			return +1
		}
	}
}

struct SWCategoryData {
	let title: String
	let identifier: String
	let icon: String
	let type: SWCategoryType
}

extension SWCategoryData {

	static var list: [SWCategoryData] {
		return SWCategoryData.expenseList + SWCategoryData.incomeList
	}

	static let expenseList: [SWCategoryData] = [
		SWCategoryData(
			title: "Foods & Drinks",
			identifier: "cat_expense_foods",
			icon: "fa-utensils",
			type: .expense
		),
		SWCategoryData(
			title: "Groceries",
			identifier: "cat_expense_groceries",
			icon: "fa-shopping-cart",
			type: .expense
		),
		SWCategoryData(
			title: "General",
			identifier: "cat_expense_general",
			icon: "fa-stream",
			type: .expense
		),
		SWCategoryData(
			title: "Transport",
			identifier: "cat_expense_transport",
			icon: "fa-subway",
			type: .expense
		),
		SWCategoryData(
			title: "Entertainment",
			identifier: "cat_expense_entertainment",
			icon: "fa-smile-beam",
			type: .expense
		),
		SWCategoryData(
			title: "Personal Care",
			identifier: "cat_expense_care",
			icon: "fa-heartbeat",
			type: .expense
		),
		SWCategoryData(
			title: "Bills",
			identifier: "cat_expense_bills",
			icon: "fa-file-invoice",
			type: .expense
		),
		SWCategoryData(
			title: "Shopping",
			identifier: "cat_expense_shopping",
			icon: "fa-shopping-bag",
			type: .expense
		),
		SWCategoryData(
			title: "Accommodation",
			identifier: "cat_expense_accommodation",
			icon: "fa-building",
			type: .expense
		),
		SWCategoryData(
			title: "Housing",
			identifier: "cat_expense_housing",
			icon: "fa-paint-roller",
			type: .expense
		),
		SWCategoryData(
			title: "Holidays",
			identifier: "cat_expense_holidays",
			icon: "fa-umbrella-beach",
			type: .expense
		),
		SWCategoryData(
			title: "Lending",
			identifier: "cat_expense_lending",
			icon: "fa-hand-holding-usd",
			type: .expense
		)
	]

	static let incomeList: [SWCategoryData] = [
		SWCategoryData(
			title: "Salary",
			identifier: "cat_income_salary",
			icon: "fa-suitcase",
			type: .income
		),
		SWCategoryData(
			title: "General",
			identifier: "cat_income_general",
			icon: "fa-stream",
			type: .income
		),
		SWCategoryData(
			title: "Gifts",
			identifier: "cat_income_gifts",
			icon: "fa-gift",
			type: .income
		),
		SWCategoryData(
			title: "Sales",
			identifier: "cat_income_sales",
			icon: "fa-chart-bar",
			type: .income
		),
		SWCategoryData(
			title: "Interests",
			identifier: "cat_income_interests",
			icon: "fa-coins",
			type: .income
		),
		SWCategoryData(
			title: "Coupon",
			identifier: "cat_income_copuns",
			icon: "fa-money-bill-wave",
			type: .income
		),
		SWCategoryData(
			title: "Supports",
			identifier: "cat_income_supports",
			icon: "fa-star",
			type: .income
		),
		SWCategoryData(
			title: "Investments",
			identifier: "cat_income_investments",
			icon: "fa-piggy-bank",
			type: .income
		),
		SWCategoryData(
			title: "Refunding Debt",
			identifier: "cat_income_refunding",
			icon: "fa-undo-alt",
			type: .income
		)
	]
}
