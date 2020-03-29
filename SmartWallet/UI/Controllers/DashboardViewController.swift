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
import Charts

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class DashboardViewController: UITableViewController {
	private var lineChartView: LineChartView?
	private var segmentioView: Segmentio?
	private var dashboardHeaderView: UIView?

	private var monthYearList = [SWMonth] ()
	private var currentYear: Int = Date().year()
	private var currentMonth: Int = Date().month()
	private var overalInfo = [(label: String, value:String)]()
	private var costInfo = [(label: String, value:String)]()
	private var budgetInfo = [(amount:Double, budget:Double)]()
	private var incomeInfo = [(label: String, value:String)]()
	private var currencyLabel = NSLocale.defaultCurrency
	private var totalBudget = 0.0
	private var monthData = ReportModel.monthlyOveralInfo()

	override func viewDidLoad() {
		super.viewDidLoad()

		dashboardHeaderView = UIView(
			frame: CGRect(
				x: 0,
				y: 0,
				width: self.view.frame.width,
				height: 260
			)
		)
		tableView.tableHeaderView = dashboardHeaderView
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		StoreReviewHelper.checkAndAskForReview()

		configureSegmentedView()
		totalBudget = Facade.share.model.getTotalBudget()

		calculateOveralInfo()
		calculateCostInfo()
		calculateIncomeInfo()
		configureChart()

		tableView.reloadData()
	}

	private func configureChart() {
		lineChartView = LineChartView(frame: CGRect(x: 0, y: 60, width: self.view.frame.width, height: 200))

		lineChartView?.delegate = self

		lineChartView?.chartDescription?.enabled = false
		lineChartView?.dragEnabled = true
		lineChartView?.setScaleEnabled(false)
		lineChartView?.pinchZoomEnabled = false
		lineChartView?.rightAxis.enabled = false

		lineChartView?.xAxis.valueFormatter = self
		lineChartView?.xAxis.granularity = 1

		lineChartView?.legend.form = .line

		lineChartView?.animate(yAxisDuration: 0.3)

		if let lineChartView = lineChartView {
			dashboardHeaderView?.subviews.filter({ $0 is LineChartView }).forEach {
				$0.removeFromSuperview()
			}
			dashboardHeaderView?.addSubview(lineChartView)
		}
		setupLineChartData()
	}

	func setupLineChartData() {
		monthData = ReportModel.monthlyOveralInfo()
		let costSet = self.provideLineData(type: .totalCost)
		let incomeSet = self.provideLineData(type: .totalIncome)

		let lineChartData = LineChartData(dataSets: [incomeSet, costSet])
		lineChartView?.data = lineChartData
		lineChartView?.setVisibleXRangeMaximum(5)
		lineChartView?.moveViewToX(lineChartView?.chartXMax ?? 0)
	}

	private func provideLineData(type: SWRepresentationType) -> LineChartDataSet {
		var mainColor: UIColor = .black
		var gradientFirstColor: UIColor = .clear
		var gradientSecondColor: UIColor = .black
		if type == .totalIncome {
			mainColor = .myAppGreen
			gradientFirstColor = .clear
			gradientSecondColor = .myAppGreen
		}

		let totalCosts = monthData.compactMap({
			$0.items.first(where: {$0.type == type})
		})

		var index: Double = -1
		let values: [ChartDataEntry] = totalCosts.compactMap({
			index += 1
			return ChartDataEntry(x: index, y: $0.value)
		})

		let chartDataSet = LineChartDataSet(entries: values, label: type.rawValue)
		chartDataSet.resetColors()
		chartDataSet.drawIconsEnabled = false

		chartDataSet.setColor(mainColor)
		chartDataSet.setCircleColor(mainColor)
		chartDataSet.lineWidth = 1
		chartDataSet.circleRadius = 3
		chartDataSet.drawCircleHoleEnabled = true
		chartDataSet.valueFont = .systemFont(ofSize: 9)

		let gradientColors = [gradientFirstColor.cgColor,
							  gradientSecondColor.cgColor]
		let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)

		chartDataSet.fillAlpha = 0.5
		if let gradient = gradient {
			chartDataSet.fill = Fill(linearGradient: gradient, angle: 90)
		}
		chartDataSet.drawFilledEnabled = true

		return chartDataSet
	}

	func configureSegmentedView() {
		let frame = tableView.frame
		let segmentioViewRect = CGRect(x: frame.minX, y: frame.minY, width: UIScreen.main.bounds.width, height: 50)
		segmentioView = Segmentio(frame: segmentioViewRect)
		segmentioView?.setup(
			content: segmentioContent(),
			style: .onlyLabel,
			options: DashboardViewController.segmentioOptions(segmentioStyle: .imageBeforeLabel)
		)
		segmentioView?.selectedSegmentioIndex = segmentioView?.segmentioItems.count ?? 0 - 1
		currentYear = monthYearList.last!.year
		currentMonth = monthYearList.last!.month

		segmentioView?.valueDidChange = { [weak self] _, index in
			self?.updateDataAt(index: index)
			self?.lineChartView?.highlightValue(x: Double(index), dataSetIndex: -1)
			self?.lineChartView?.centerViewToAnimated(xValue: Double(index), yValue: 0, axis: .left, duration: 0.3)
		}

		if let segmentioView = segmentioView {
			dashboardHeaderView?.addSubview(segmentioView)
		}
	}

	func calculateOveralInfo() {
		overalInfo.removeAll()

		let numDays = Date.getMonthDuration(year: currentYear, month: currentMonth, considerCurrent: true)
		let numDaysAll =  Date.getMonthDuration(year: currentYear, month: currentMonth, considerCurrent: false)

		let monthlyTotalCost = Facade.share.model.getTotalMonth(year: currentYear, month: currentMonth, type: .cost)
		let dailyAverageCost = monthlyTotalCost / Double(numDays)

		let monthlyTotalIncome = Facade.share.model.getTotalMonth(year: currentYear,
																  month: currentMonth,
																  type: .income)
		let dailyAverageIncome = monthlyTotalIncome / Double(numDays)

		let monthlyTotal = monthlyTotalIncome - monthlyTotalCost
		let dailyAverage = dailyAverageIncome - dailyAverageCost

		overalInfo.append((
			"Total Cost",
			monthlyTotalCost.recordPresenter(for: .cost)
		))
		overalInfo.append((
			"Total Income",
			monthlyTotalIncome.recordPresenter(for: .income)
		))
		overalInfo.append((
			"Total",
			monthlyTotal.recordPresenter(for: .all)
		))

		if totalBudget > 0 {
			let monthlyTotalSave = totalBudget - monthlyTotalCost
			overalInfo.append((
				"Total Save",
				monthlyTotalSave.recordPresenter(for: .all)
			))
		}

		overalInfo.append((" ", " "))

		overalInfo.append((
			"Daily Average",
			dailyAverage.recordPresenter(for: .all)
		))
		overalInfo.append((
			"Daily Average Cost",
			dailyAverageCost.recordPresenter(for: .cost)
		))
		overalInfo.append((
			"Daily Average Income",
			dailyAverageIncome.recordPresenter(for: .income)
		))

		if Date().year() == currentYear && Date().month() == currentMonth {
			overalInfo.append((" ", " "))

			let monthlyForecast = dailyAverage * Double(numDaysAll)
			overalInfo.append((
				"Monthly Forecast",
				monthlyForecast.recordPresenter(for: .all)
			))

			let monthlyForecastCost = dailyAverageCost * Double(numDaysAll)
			overalInfo.append((
				"Monthly Forecast Cost",
				monthlyForecastCost.recordPresenter(for: .cost)
			))

			let monthlyForecastIncome = dailyAverageIncome * Double(numDaysAll)
			overalInfo.append((
				"Monthly Forecast Income",
				monthlyForecastIncome.recordPresenter(for: .income)
			))
		}

	}

	func calculateCostInfo() {
		costInfo.removeAll()
		budgetInfo.removeAll()
		let catWithCost = Facade.share.model.getMonthlyTotalByCategory(year: currentYear,
																	   month: currentMonth,
																	   type: .cost)
		for result in catWithCost {
			costInfo.append((
				label: result.category.name,
				value: result.amount.recordPresenter(for: .cost)
			))
			budgetInfo.append((amount: result.amount, budget: result.category.budget))
		}
	}

	func calculateIncomeInfo() {
		incomeInfo.removeAll()
		let catWithCost = Facade.share.model.getMonthlyTotalByCategory(year: currentYear,
																	   month: currentMonth,
																	   type: .income)
		for result in catWithCost {
			incomeInfo.append((
				label: result.category.name,
				value: result.amount.recordPresenter(for: .income)
			))
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
			cell.selectionStyle = .none

			cell.textLabel?.text = overalInfo[indexPath.row].label
			cell.detailTextLabel?.text = overalInfo[indexPath.row].value

			return cell
		} else if indexPath.section == 1 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "dashboardCostCell", for: indexPath) as! BudgetTableViewCell
			cell.selectionStyle = .none

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
			cell.selectionStyle = .none

			cell.textLabel?.text = incomeInfo[indexPath.row].label
			cell.detailTextLabel?.text = incomeInfo[indexPath.row].value
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "dashboardCell", for: indexPath)
			cell.selectionStyle = .none
			return cell
		}
	}

	private func segmentioContent() -> [SegmentioItem] {
		let (minDate, maxDate) = Facade.share.model.getMinMaxDateInRecords()
		self.monthYearList = Date.monthsBetweenDates(
			startDate: minDate,
			endDate: maxDate)

		return self.monthYearList.compactMap {
			return SegmentioItem(title: $0.titleWithCurrentYear, image: nil)
		}
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

	private func updateDataAt(index: Int) {
		guard let currentYear = self.monthYearList[safe: index]?.year,
			let currentMonth = self.monthYearList[safe: index]?.month else {
				assertionFailure("No data for selected index")
				return
		}
		self.currentYear = currentYear
		self.currentMonth = currentMonth

		self.totalBudget = Facade.share.model.getTotalBudget()
		self.currencyLabel = NSLocale.defaultCurrency

		self.calculateOveralInfo()
		self.calculateCostInfo()
		self.calculateIncomeInfo()

		self.tableView.reloadData()
	}

}

extension DashboardViewController: ChartViewDelegate {
	func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
		let index = Int(entry.x)
		self.updateDataAt(index: index)
		segmentioView?.selectedSegmentioIndex = index
	}

}

extension DashboardViewController: IAxisValueFormatter {
	func stringForValue( _ value: Double, axis _: AxisBase?) -> String {
		let yearMonth = monthData[safe: Int(value)]?.month
		if let month = yearMonth?.shortTitleWithCurrentYear {
			return month
		}
		return ""
	}
}
