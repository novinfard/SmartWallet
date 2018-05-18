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
	
	var commitPredicate: NSPredicate?
	var fetchedResultsController: NSFetchedResultsController<Records>!
	
	let style: Style = Style.myApp
	var coverImageView = UIImageView()
	
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
			let calendar = Calendar.current
			if calendar.isDateInToday(topRecord.datetime) {
				return "Today"
			} else if calendar.isDateInYesterday(topRecord.datetime) {
				return "Yesterday"
			} else if calendar.isDate(Date(), equalTo: topRecord.datetime, toGranularity: .weekOfYear) {
				let formatter = DateFormatter()
				let weekday = calendar.component(.weekday, from: topRecord.datetime)
				return formatter.weekdaySymbols[weekday-1]
			} else {
				let formatter = DateFormatter()
				formatter.dateStyle = .medium
				return formatter.string(from: topRecord.datetime)
			}
		} else {
			return sectionInfo.indexTitle
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath) as! RecordTableViewCell
		let record = fetchedResultsController.object(at: indexPath)
		if record.direction > 0 {
			cell.icon.image = UIImage(named: "UpIcon")
			cell.amountLabel.textColor = UIColor.myAppGreen
			cell.amountLabel.text = getRecordString(record.amount, .recordTypeIncome, formatting:false)
		} else {
			cell.icon.image = UIImage(named: "DownIcon")
			cell.amountLabel.textColor = UIColor.myAppRed
			cell.amountLabel.text = getRecordString(record.amount, .recordTypeCost, formatting:false)
		}
		cell.titleLabel.text = record.relatedCategory.name
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			let record = fetchedResultsController.object(at: indexPath)
			Facade.share.model.container.viewContext.delete(record)
			Facade.share.model.saveContext()
			do {
				try fetchedResultsController.performFetch()
				tableView.reloadData()
			} catch {
				print("Fetch failed")
			}
//			tableView.deleteRows(at: [indexPath], with: .fade)
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let record = fetchedResultsController.object(at: indexPath)
//		let controller = AddRecordViewController()
		
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let controller = storyboard.instantiateViewController(withIdentifier: "AddRecord") as! AddRecordViewController

		controller.currentUid = record.uid
		navigationController?.pushViewController(controller, animated: true)
	}
	
	
	
	func loadSavedData() {
		if fetchedResultsController == nil {
			let request = Records.createFetchRequest()
			let sort = NSSortDescriptor(key: "datetime", ascending: false)
			let sort2 = NSSortDescriptor(key: "uid", ascending: false)

			request.sortDescriptors = [sort, sort2]
			request.fetchBatchSize = 20
			
			fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: Facade.share.model.container.viewContext, sectionNameKeyPath: "datetime", cacheName: nil)
			fetchedResultsController.delegate = self
		}
		
		fetchedResultsController.fetchRequest.predicate = commitPredicate
		
		do {
			try fetchedResultsController.performFetch()
			if fetchedResultsController.fetchedObjects?.count == 0 {
				tableView.separatorStyle = .none
			} else {
				tableView.separatorStyle = .singleLine
			}
			tableView.reloadData()
		} catch {
			print("Fetch failed")
		}
		
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		if fetchedResultsController.fetchedObjects?.count == 0 {
			let coverImage = UIImage(named: "AddFirstRecord")!
			coverImageView.image = coverImage
			coverImageView.contentMode = .scaleAspectFit
			coverImageView.frame = CGRect(x: 20, y: 5, width: tableView.frame.width-20, height: 300)
			view.addSubview(coverImageView)
			
		} else {
			DispatchQueue.main.async {
				self.coverImageView.removeFromSuperview()
			}
		}
	}
	
}
