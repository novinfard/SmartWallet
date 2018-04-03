//
//  RecordsViewController.swift
//  SmartWallet
//
//  Created by Soheil on 21/01/2018.
//  Copyright © 2018 Soheil Novinfard. All rights reserved.
//

import UIKit
import CoreData

class RecordsViewController: UITableViewController, NSFetchedResultsControllerDelegate {
	
	var container: NSPersistentContainer!
	var commitPredicate: NSPredicate?
	var fetchedResultsController: NSFetchedResultsController<Records>!
	
	let style: Style = Style.myApp
	
//	init(style: Style) {
//		self.style = style
//		super.init(nibName: nil, bundle: nil)
//	}
//
//	required init?(coder aDecoder: NSCoder) {
//		super.init(coder: aDecoder)
//	}
	
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return style.preferredStatusBarStyle
	}

    override func viewDidLoad() {
		super.viewDidLoad()
		
		applyStyle()

		// initialise core data
		container = NSPersistentContainer(name: "WalletModel")
		
		container.loadPersistentStores { (storeDescription, error) in
			self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
			
			if let error = error {
				print("Unsolved error \(error.localizedDescription)")
			}
		}
		
		do {
			let fetchRequest : NSFetchRequest<Accounts> = Accounts.createFetchRequest()
//			fetchRequest.predicate = NSPredicate(format: "uniqueId == %@", contactIdentifier)
			let result = try container.viewContext.fetch(fetchRequest)
			// luncdhing data initialisation
			if result.count == 0 {
				// add a default account
				let account = Accounts(context: self.container.viewContext)
				account.currency = "£"
				account.initial = 0
				account.name = "Default Account"
				account.uid = UUID().uuidString
				
				saveContext()
				
				// pre-defined cateogories import
				let expenseCategoryNames = ["Foods & Drinks", "Shopping", "Housing", "Transportation", "Financial Expenses", "Entertainment", "Others"]
				let incomeCategoryNames = ["Investments", "Gifts", "Copuns", "Rental Income", "Sale", "Interests"]
				
				for categoryName in expenseCategoryNames {
					let category = Categories(context: self.container.viewContext)
					category.direction = -1
					category.name = categoryName
					category.parent = ""
				}
				
				for categoryName in incomeCategoryNames {
					let category = Categories(context: self.container.viewContext)
					category.direction = 1
					category.name = categoryName
					category.parent = ""
				}
				
				saveContext()
			}
		}
		catch {
			print ("fetch task failed", error)
		}
		
		// if there is any need to load data from server #ONLINE
//		performSelector(inBackground: #selector(fetchRecords), with:nil)
		
		self.loadSavedData();
    }
	
	func applyStyle() {
        view.backgroundColor = style.backgroundColor
		
//		style.apply(textStyle: .title, to: tableView.visibleCells)
//		style.apply(textStyle: .subtitle, to: subtitleLabel)
//		style.apply(textStyle: .body, to: bodyLabel)
//		style.apply(to: actionButton)
		
        if let navBar = navigationController?.navigationBar {
            style.apply(to: navBar)
        }
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return fetchedResultsController.sections?.count ?? 0
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sectionInfo = fetchedResultsController.sections![section]
		return sectionInfo.numberOfObjects
		
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath)
		let record = fetchedResultsController.object(at: indexPath)
		
		if record.direction > 0 {
			cell.detailTextLabel!.text = "Income"
			cell.backgroundColor = UIColor.myAppLightGreen
		} else {
			cell.detailTextLabel!.text = "Cost"
			cell.backgroundColor = UIColor.myAppLightOrange
		}
		cell.textLabel?.text = "\(record.amount)"
		
		return cell
	}
	
	func loadSavedData() {
		if fetchedResultsController == nil {
			let request = Records.createFetchRequest()
			let sort = NSSortDescriptor(key: "datetime", ascending: false)
			request.sortDescriptors = [sort]
			request.fetchBatchSize = 20
			
			fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: "datetime", cacheName: nil)
			fetchedResultsController.delegate = self
		}
		
		fetchedResultsController.fetchRequest.predicate = commitPredicate
		
		do {
			try fetchedResultsController.performFetch()
			tableView.reloadData()
		} catch {
			print("Fetch failed")
		}
		
	}
	
	func addSampleData() {
		let record = Records(context: self.container.viewContext)
		record.amount = drand48() * 20;
		record.datetime = Date()
		record.direction = drand48() > 0.5 ? 1 : -1
		record.note = ""
		record.reported = true
		record.uid = UUID().uuidString
		
		saveContext()
	}
	
	func saveContext() {
		if container.viewContext.hasChanges {
			do {
				try container.viewContext.save()
			} catch {
				print("An error occurred while saving: \(error)")
			}
		}
	}

}
