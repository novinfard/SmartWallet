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
		
		// if there is any need to load data from server #ONLINE
//		performSelector(inBackground: #selector(fetchRecords), with:nil)
		
		self.loadSavedData();
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.loadSavedData();
	}
	
//	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//		self.loadSavedData()
//	}
	
	func applyStyle() {
//		view.backgroundColor = style.backgroundColor
		
//		style.apply(textStyle: .title, to: tableView.visibleCells)
//		style.apply(textStyle: .subtitle, to: subtitleLabel)
//		style.apply(textStyle: .body, to: bodyLabel)
//		style.apply(to: actionButton)
		
//		if let navBar = navigationController?.navigationBar {
//			style.apply(to: navBar)
//		}
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
//		print(fetchedResultsController.sections?.count ?? 1100)
		return fetchedResultsController.sections?.count ?? 0
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sectionInfo = fetchedResultsController.sections![section]
		return sectionInfo.numberOfObjects
		
	}
	
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let sectionInfo = fetchedResultsController.sections![section]
		let objects = sectionInfo.objects
		if let topRecord:Records = objects![0] as? Records  {
			let formatter = DateFormatter()
			formatter.dateStyle = .medium
			return formatter.string(from: topRecord.datetime)
		} else {
			return sectionInfo.indexTitle
		}
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath) as! RecordTableViewCell
		let record = fetchedResultsController.object(at: indexPath)
		if record.direction > 0 {
			cell.amoutPrefixLabel.text = "+£"
			cell.icon.image = UIImage(named: "IncomeIcon")
			cell.amountLabel.textColor = UIColor.myAppGreen
			cell.amoutPrefixLabel.textColor = UIColor.myAppGreen
		} else {
			cell.amoutPrefixLabel.text = "-£"
			cell.icon.image = UIImage(named: "ExpenseIcon")
			cell.amountLabel.textColor = UIColor.myAppRed
			cell.amoutPrefixLabel.textColor = UIColor.myAppRed
		}
		cell.amountLabel.text = "\(record.amount)"
		cell.titleLabel.text = record.relatedCategory.name
		
		return cell
	}
	
	func loadSavedData() {
		if fetchedResultsController == nil {
			let request = Records.createFetchRequest()
			let sort = NSSortDescriptor(key: "datetime", ascending: false)
			let sort2 = NSSortDescriptor(key: "uid", ascending: false)

			request.sortDescriptors = [sort, sort2]
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
