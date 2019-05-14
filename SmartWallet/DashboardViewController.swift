//
//  DashboardViewController.swift
//  SmartWallet
//
//  Created by Soheil on 21/01/2018.
//  Copyright © 2018 Soheil Novinfard. All rights reserved.
//

import UIKit
import Segmentio
import CoreData

class DashboardViewController: UITableViewController {

	var segmentioView: Segmentio!
	var monthYearList = [(year: Int, month: Int, title: String)] ()
	var currentYear: Int = Date().year()
	var currentMonth: Int = Date().month()
	var overalInfo = [(label: String, value:String)]()
	var costInfo = [(label: String, value:String)]()
	var budgetInfo = [(amount:Double, budget:Double)]()
	var incomeInfo = [(label: String, value:String)]()
	var currencyLabel = ""
	var totalBudget = 0.0

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.

	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		configureSegmentedView()
		StoreReviewHelper.checkAndAskForReview()

		totalBudget = Facade.share.model.getTotalBudget()
		currencyLabel = getCurrencyLabel()

		calculateOveralInfo()
		calculateCostInfo()
		calculateIncomeInfo()

		tableView.reloadData()
	}

	func configureSegmentedView() {
		let frame = tableView.frame
		let segmentioViewRect = CGRect(x: frame.minX, y: frame.minY, width: UIScreen.main.bounds.width, height: 50)
		segmentioView = Segmentio(frame: segmentioViewRect)
		segmentioView.setup(
			content: segmentioContent(),
			style: .onlyLabel,
			options: DashboardViewController.segmentioOptions(segmentioStyle: .imageBeforeLabel)
		)
		segmentioView.selectedSegmentioIndex = segmentioView.segmentioItems.count-1
		currentYear = monthYearList.last!.year
		currentMonth = monthYearList.last!.month

		segmentioView.valueDidChange = { [weak self] _, segmentIndex in
			self?.currentYear = (self?.monthYearList[segmentIndex].year)!
			self?.currentMonth = (self?.monthYearList[segmentIndex].month)!

			self?.totalBudget = Facade.share.model.getTotalBudget()
			self?.currencyLabel = getCurrencyLabel()

			self?.calculateOveralInfo()
			self?.calculateCostInfo()
			self?.calculateIncomeInfo()

			self?.tableView.reloadData()
		}

		tableView.tableHeaderView = segmentioView

	}

	func calculateOveralInfo() {
		overalInfo.removeAll()

		let numDays = getMonthDuration(year: currentYear, month: currentMonth, considerCurrent: true)
		let numDaysAll = getMonthDuration(year: currentYear, month: currentMonth, considerCurrent: false)

		let monthlyTotalCost = Facade.share.model.getTotalMonth(year: currentYear, month: currentMonth, type: .recordTypeCost)
		let dailyAverageCost = monthlyTotalCost / Double(numDays)

		let monthlyTotalIncome = Facade.share.model.getTotalMonth(year: currentYear,
																  month: currentMonth,
																  type: .recordTypeIncome)
		let dailyAverageIncome = monthlyTotalIncome / Double(numDays)

		let monthlyTotal = monthlyTotalIncome - monthlyTotalCost
		let dailyAverage = dailyAverageIncome - dailyAverageCost

		overalInfo.append(("Total", getRecordString(monthlyTotal, .recordTypeAll)))
		overalInfo.append(("Total Cost", getRecordString(monthlyTotalCost, .recordTypeCost)))
		overalInfo.append(("Total Income", getRecordString(monthlyTotalIncome, .recordTypeIncome)))

		if totalBudget > 0 {
			let monthlyTotalSave = totalBudget - monthlyTotalCost
			overalInfo.append(("Total Save", getRecordString(monthlyTotalSave, .recordTypeAll)))
		}

		overalInfo.append((" ", " "))

		overalInfo.append(("Daily Average", getRecordString(dailyAverage, .recordTypeAll)))
		overalInfo.append(("Daily Average Cost", getRecordString(dailyAverageCost, .recordTypeCost)))
		overalInfo.append(("Daily Average Income", getRecordString(dailyAverageIncome, .recordTypeIncome)))

		if Date().year() == currentYear && Date().month() == currentMonth {
			overalInfo.append((" ", " "))

			let monthlyForecast = dailyAverage * Double(numDaysAll)
			overalInfo.append(("Monthly Forecast", getRecordString(monthlyForecast, .recordTypeAll)))

			let monthlyForecastCost = dailyAverageCost * Double(numDaysAll)
			overalInfo.append(("Monthly Forecast Cost", getRecordString(monthlyForecastCost, .recordTypeCost)))

			let monthlyForecastIncome = dailyAverageIncome * Double(numDaysAll)
			overalInfo.append(("Monthly Forecast Income", getRecordString(monthlyForecastIncome, .recordTypeIncome)))
		}

	}

	func calculateCostInfo() {
		costInfo.removeAll()
		budgetInfo.removeAll()
		let catWithCost = Facade.share.model.getMonthlyTotalByCategory(year: currentYear,
																	   month: currentMonth,
																	   type: .recordTypeCost)
		for result in catWithCost {
			costInfo.append((label: result.category.name, value: getRecordString(result.amount, .recordTypeCost)))
			budgetInfo.append((amount: result.amount, budget: result.category.budget))
		}
	}

	func calculateIncomeInfo() {
		incomeInfo.removeAll()
		let catWithCost = Facade.share.model.getMonthlyTotalByCategory(year: currentYear,
																	   month: currentMonth,
																	   type: .recordTypeIncome)
		for result in catWithCost {
			incomeInfo.append((label: result.category.name, value: getRecordString(result.amount, .recordTypeIncome)))
		}
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 3
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return overalInfo.count
		case 1:
			return costInfo.count
		case 2:
			return incomeInfo.count
		default:
			return 0
		}
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			if self.tableView(tableView, numberOfRowsInSection: 0) > 0 {
				return "General Info"
			}
		case 1:
			if self.tableView(tableView, numberOfRowsInSection: 1) > 0 {
				return "Your Costs"
			}
		case 2:
			if self.tableView(tableView, numberOfRowsInSection: 2) > 0 {
				return "Your Incomes"
			}
		default:
			return nil
		}
		return nil
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "dashboardCell", for: indexPath)
			cell.textLabel?.text = overalInfo[indexPath.row].label
			cell.detailTextLabel?.text = overalInfo[indexPath.row].value

			return cell
		} else if indexPath.section == 1 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "dashboardCostCell", for: indexPath) as! BudgetTableViewCell
			let calc = budgetInfo[indexPath.row]

			cell.categoryLabel.text = costInfo[indexPath.row].label
			if costInfo[indexPath.row].value != "" {
				if calc.budget != 0 {
					cell.budgetAmount.text = "\(costInfo[indexPath.row].value) / \(calc.budget.clean)"
				} else {
					cell.budgetAmount.text = "\(costInfo[indexPath.row].value)"
				}
			} else {
				cell.budgetAmount.text = ""
				cell.budgetPercentage.progress = 0
			}

			if calc.amount != 0 && calc.budget != 0 {
				let share = calc.amount / calc.budget
				if share > 1 {
					cell.budgetPercentage.progress = Float(1 / share)
					cell.budgetPercentage.progressTintColor = UIColor.blue
					cell.budgetPercentage.trackTintColor = UIColor.red
				} else {
					cell.budgetPercentage.progress = Float(share)
					cell.budgetPercentage.progressTintColor = UIColor.blue
					cell.budgetPercentage.trackTintColor = UIColor.lightGray
				}
			} else {
				cell.budgetPercentage.progress = 0
			}

			cell.budgetAmount.isEnabled = false

			return cell
		} else if indexPath.section == 2 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "dashboardCell", for: indexPath)
			cell.textLabel?.text = incomeInfo[indexPath.row].label
			cell.detailTextLabel?.text = incomeInfo[indexPath.row].value
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "dashboardCell", for: indexPath)
			return cell
		}
	}

	private func segmentioContent() -> [SegmentioItem] {
		let (minDate, maxDate) = Facade.share.model.getMinMaxDateInRecords()
		monthYearList = monthsBetweenDates(
			startDate: minDate,
			endDate: maxDate,
			displayType: .monthsWithyearExceptCurrentTuple) as! [(year: Int, month: Int, title: String)]

		var items = [SegmentioItem]()
		for case let monthYear in monthYearList {
			items.append(SegmentioItem(title: monthYear.title, image: nil))
		}
		return items
	}

	private static func segmentioOptions(
		segmentioStyle: SegmentioStyle,
		segmentioPosition: SegmentioPosition = .fixed(maxVisibleItems: 3))
		-> SegmentioOptions {
		var imageContentMode = UIView.ContentMode.center
		switch segmentioStyle {
		case .imageBeforeLabel, .imageAfterLabel:
			imageContentMode = .scaleAspectFit

		default:
			break
		}

		return SegmentioOptions(
			backgroundColor: UIColor.white,
			segmentPosition: segmentioPosition,
			scrollEnabled: true,
			//			indicatorOptions: segmentioIndicatorOptions(),
			horizontalSeparatorOptions: SegmentioHorizontalSeparatorOptions(
				type: SegmentioHorizontalSeparatorType.bottom, // Top, Bottom, TopAndBottom
				height: 1,
				color: .lightGray
			),
			verticalSeparatorOptions: SegmentioVerticalSeparatorOptions(
				ratio: 0.6, // from 0.1 to 1
				color: .lightGray
			),
			imageContentMode: imageContentMode,
			labelTextAlignment: .center,
			labelTextNumberOfLines: 1,
			//			segmentStates: segmentioStates(),
			animationDuration: 0.3
		)
	}

}
