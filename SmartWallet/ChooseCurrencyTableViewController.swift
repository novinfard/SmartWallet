//
//  ChooseCurrencyTableViewCell.swift
//  SmartWallet
//
//  Created by Soheil on 08/04/2018.
//  Copyright © 2018 Soheil Novinfard. All rights reserved.
//

import UIKit

class ChooseCurrencyTableViewController: UITableViewController {

	var currencyList = [Currency]()
	let currencyCurrencySymbol = UserDefaults.standard.string(forKey: "currencySymbol")

	override func viewDidLoad() {
		super.viewDidLoad()

		let currecy = Currency()
		currencyList = currecy.loadEveryCountryWithCurrency()
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return currencyList.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath)
		cell.backgroundColor = UIColor.white

		let currencyItem = currencyList[indexPath.row]

		cell.detailTextLabel?.text = currencyItem.currencySymbol!

		if currencyCurrencySymbol == currencyItem.currencySymbol {
			cell.textLabel?.text = currencyItem.currencyName! + " ✓"

			cell.backgroundColor = UIColor.myAppLightGreen
//			cell.detailTextLabel?.textColor = UIColor.myAppGreen
//			cell.textLabel?.textColor = UIColor.myAppGreen
		} else {
			cell.textLabel?.text = currencyItem.currencyName
		}

		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let currencyItem = currencyList[indexPath.row]
		UserDefaults.standard.set(currencyItem.currencySymbol, forKey: "currencySymbol")

		navigationController?.popViewController(animated: true)
	}

}
