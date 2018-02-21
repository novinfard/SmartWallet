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

    override func viewDidLoad() {
		super.viewDidLoad()

		// initialise core data
		container = NSPersistentContainer(name: "WalletModel")
		
		container.loadPersistentStores { (storeDescription, error) in
			self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
			
			if let error = error {
				print("Unsolved error \(error.localizedDescription)")
			}
		}
		
		addSampleData()
		addSampleData()
		addSampleData()

		
		// if there is any need to load data from server #ONLINE
//		performSelector(inBackground: #selector(fetchRecords), with:nil)
		
		self.loadSavedData();
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
		
		cell.detailTextLabel!.text = record.direction > 0 ? "Deposit" : "Withdraw"
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
