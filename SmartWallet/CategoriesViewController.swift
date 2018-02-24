//
//  CategoriesViewController.swift
//  SmartWallet
//
//  Created by Soheil on 24/02/2018.
//  Copyright © 2018 Soheil Novinfard. All rights reserved.
//

import UIKit
import CoreData

class CategoriesViewController: UITableViewController, NSFetchedResultsControllerDelegate {
	
	var container: NSPersistentContainer!
	var generalPredicate: NSPredicate?
	var fetchedResultsController: NSFetchedResultsController<Categories>!
	var topSegments: UISegmentedControl!
	var filterDirection: Int = -1
	
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
		
		// if there is any need to load data from server #ONLINE
		//		performSelector(inBackground: #selector(fetchRecords), with:nil)
		
		self.loadSavedData();
	
		let items = ["Expense", "Income"]
		topSegments = UISegmentedControl(items: items)
		topSegments.selectedSegmentIndex = 0
		topSegments.layer.cornerRadius = 0
		topSegments.layer.borderWidth = 1.0
		topSegments.layer.borderColor = UIColor.blue.cgColor
		topSegments.layer.masksToBounds = true
		let frame = tableView.frame
		topSegments.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: 20)
		topSegments.addTarget(self, action: #selector(filterChanged(_:)), for: .valueChanged)
		tableView.tableHeaderView = topSegments
		
//		let headerView: UIView = UIView.init(frame: CGRect(x:1, y:50, width:276, height:30));
//		headerView.backgroundColor = UIColor(red: 235/255.0, green: 235/255.0, blue: 235/255.0, alpha: 1.0)
//
//		let labelView: UILabel = UILabel.init(frame: CGRect(x:4, y:5, width:276, height:24))
//		labelView.text = "hello"
//
//		headerView.addSubview(labelView)
//		tableView.tableHeaderView = headerView

	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return fetchedResultsController.sections?.count ?? 0
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sectionInfo = fetchedResultsController.sections![section]
		return sectionInfo.numberOfObjects
		
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
		let category = fetchedResultsController.object(at: indexPath)
		
		cell.textLabel?.text = category.name
		cell.detailTextLabel?.text = category.direction > 0 ? "+" : "-"
		
		return cell
	}
	
//	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//		return fetchedResultsController.sections![section].name
//	}
	
	func loadSavedData() {
		if fetchedResultsController == nil {
			let request = Categories.createFetchRequest()
			let sort = NSSortDescriptor(key: "direction", ascending: false)
			request.sortDescriptors = [sort]
			request.fetchBatchSize = 20
			
			fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: "direction", cacheName: nil)
			fetchedResultsController.delegate = self
		}
		
		generalPredicate = NSPredicate(format: "direction = %d", filterDirection)
		fetchedResultsController.fetchRequest.predicate = generalPredicate
		
		do {
			try fetchedResultsController.performFetch()
			tableView.reloadData()
		} catch {
			print("Fetch failed")
		}
		
	}
	
	func addSampleData() {
		let cateory = Categories(context: self.container.viewContext)
		cateory.name = "Test " + UUID().uuidString.prefix(5)
		cateory.direction = drand48() > 0.5 ? 1 : -1
		cateory.uid = UUID().uuidString
		
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
	
	@objc func filterChanged(_ segControl: UISegmentedControl) {
		
		switch segControl.selectedSegmentIndex {
		case 0:
			filterDirection = -1
		case 1:
			filterDirection = 1
		default:
			break
		}
		
		loadSavedData()
	}
	
}
