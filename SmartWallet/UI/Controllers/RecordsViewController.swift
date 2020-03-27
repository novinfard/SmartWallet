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

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return style.preferredStatusBarStyle
	}

    override func viewDidLoad() {
		super.viewDidLoad()

		self.loadSavedData()
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.loadSavedData()
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return fetchedResultsController.sections?.count ?? 0
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sectionInfo = fetchedResultsController.sections![section]
		return sectionInfo.numberOfObjects

	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		guard let sectionInfo = fetchedResultsController.sections?[section] else {
			return nil
		}

		let objects = sectionInfo.objects
		if let topRecord: Records = objects?[0] as? Records {
			return topRecord.datetime.dayRepresentation()
		} else {
			return sectionInfo.indexTitle
		}
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 60
	}

	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

		guard let sectionInfo = fetchedResultsController.sections?[section] else {
			return nil
		}

		guard let records = sectionInfo.objects as? [Records],
			let topRecord = records.first else {
			return nil
		}
		
		let headerView = SWRecordHeaderView()
		headerView.setup(with: SWRecordHeaderViewModel(
			title: topRecord.datetime.dayRepresentation(),
			spending: records.sum().value.recordPresenter(
				for: .all,
				formatting: false
		)))
		return headerView
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath) as? RecordTableViewCell else {
			assertionFailure("Cell not found: RecordTableViewCell")
			return UITableViewCell()
		}

		let record = fetchedResultsController.object(at: indexPath)
		if record.direction > 0 {
			cell.amountLabel.textColor = UIColor.myAppGreen
			cell.amountLabel.text = record.amount.recordPresenter(for: .income, formatting: false)
		} else {
			cell.amountLabel.textColor = UIColor.myAppBlack
			cell.amountLabel.text = record.amount.recordPresenter(for: .cost, formatting: false)
		}
		cell.icon.image = record.relatedCategory.iconImage()
		cell.titleLabel.text = record.relatedCategory.name

		return cell
	}

	override func tableView(
		_ tableView: UITableView,
		commit editingStyle: UITableViewCell.EditingStyle,
		forRowAt indexPath: IndexPath) {
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
		}
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let record = fetchedResultsController.object(at: indexPath)

		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let controller = storyboard.instantiateViewController(withIdentifier: "DisplayRecord") as! DisplayRecordViewController

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

			fetchedResultsController = NSFetchedResultsController(
				fetchRequest: request,
				managedObjectContext: Facade.share.model.container.viewContext,
				sectionNameKeyPath: "datetime",
				cacheName: nil)
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
