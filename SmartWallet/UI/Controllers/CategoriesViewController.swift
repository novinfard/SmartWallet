//
//  CategoriesViewController.swift
//  SmartWallet
//
//  Created by Soheil on 24/02/2018.
//  Copyright © 2018 Soheil Novinfard. All rights reserved.
//

import UIKit
import CoreData
import Segmentio
import FontAwesome

class CategoriesViewController: UITableViewController, NSFetchedResultsControllerDelegate {

	var generalPredicate: NSPredicate?
	var fetchedResultsController: NSFetchedResultsController<Categories>!
	var topSegments: UISegmentedControl!
	var filterDirection: Int = -1
	var segmentioView: Segmentio!
	@IBOutlet weak var editButton: UIBarButtonItem!

	override func viewDidLoad() {
		super.viewDidLoad()

		// tapRecognizer, placed in viewDidLoad
		// Disabled becuase of conflict wit
//		let longPressRecognizer = UILongPressGestureRecognizer(target: self, action:#selector(self.longPress(_:)))
//		self.view.addGestureRecognizer(longPressRecognizer)

		self.loadSavedData()

		// if there is any need to load data from server #ONLINE
		//		performSelector(inBackground: #selector(fetchRecords), with:nil)

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

		let segmentioViewRect = CGRect(x: frame.minX, y: frame.minY, width: UIScreen.main.bounds.width, height: 50)
		segmentioView = Segmentio(frame: segmentioViewRect)
		segmentioView.setup(
			content: CategoriesViewController.segmentioContent(),
			style: .imageBeforeLabel,
			options: CategoriesViewController.segmentioOptions(segmentioStyle: .imageBeforeLabel)
		)
		segmentioView.selectedSegmentioIndex = 0
		segmentioView.valueDidChange = { [weak self] _, segmentIndex in
			switch segmentIndex {
			case 0:
				self?.filterDirection = -1
			case 1:
				self?.filterDirection = 1
			default:
				break
			}
			self?.loadSavedData()
		}

		tableView.tableHeaderView = segmentioView

//		tableView.tableHeaderView = topSegments

//		let headerView: UIView = UIView.init(frame: CGRect(x:1, y:50, width:276, height:30));
//		headerView.backgroundColor = UIColor(red: 235/255.0, green: 235/255.0, blue: 235/255.0, alpha: 1.0)
//
//		let labelView: UILabel = UILabel.init(frame: CGRect(x:4, y:5, width:276, height:24))
//		labelView.text = "hello"
//
//		headerView.addSubview(labelView)
//		tableView.tableHeaderView = headerView

	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		editingEnd()
	}

	@IBAction func editPressed(_ sender: Any) {
		if self.isEditing {
			editingEnd()
		} else {
			editingBegin()
		}
	}

	@objc func longPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {

		if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {

			let touchPoint = longPressGestureRecognizer.location(in: self.view)
			if tableView.indexPathForRow(at: touchPoint) != nil {
				// your code here, get the row for the indexPath or do whatever you want
				if !self.isEditing {
					editingBegin()
				}
			}
		}
	}

	func editingBegin() {
		self.isEditing = true
		self.editButton.style = .done
		self.editButton.title = "Done"
	}

	func editingEnd() {
		self.isEditing = false
		self.editButton.style = .plain
		self.editButton.title = "Edit"
//		loadSavedData()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

//		self.tableView.reloadData()
		self.loadSavedData()
	}

//	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
////		self.tableView.reloadData()
//	}

	private static func segmentioContent() -> [SegmentioItem] {
		return [
			SegmentioItem(title: "Expense", image: UIImage(named: "ExpenseIcon")),
			SegmentioItem(title: "Income", image: UIImage(named: "IncomeIcon"))
		]
	}

	private static func segmentioOptions(
		segmentioStyle: SegmentioStyle,
		segmentioPosition: SegmentioPosition = .fixed(maxVisibleItems: 3)) -> SegmentioOptions {
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

	func loadSavedData() {
		if fetchedResultsController == nil {
			let request = Categories.createFetchRequest()
			let sort = NSSortDescriptor(key: "sortId", ascending: false)
			request.sortDescriptors = [sort]
			request.fetchBatchSize = 20

			fetchedResultsController = NSFetchedResultsController(
				fetchRequest: request,
				managedObjectContext: Facade.share.model.container.viewContext,
				sectionNameKeyPath: "direction",
				cacheName: nil)
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

	func saveContext() {
		Facade.share.model.saveContext()
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

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		UserDefaults.standard.set(segmentioView.selectedSegmentioIndex, forKey: "DirectionInAddCategories")
	}

}

// MARK: TableView DataSource
extension CategoriesViewController {

	override func numberOfSections(in tableView: UITableView) -> Int {
		return fetchedResultsController.sections?.count ?? 0
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sectionInfo = fetchedResultsController.sections![section]
		return sectionInfo.numberOfObjects
	}

	override func tableView(
		_ tableView: UITableView,
		commit editingStyle: UITableViewCell.EditingStyle,
		forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			let category = fetchedResultsController.object(at: indexPath)

			if Facade.share.model.getNumberOfRecordsInCategory(uid: category.uid) == 0 {

				Facade.share.model.container.viewContext.delete(category)
				Facade.share.model.saveContext()
			} else {
				let alert = UIAlertController(
					title: "Error",
					message: "You should remove all records in this category first",
					preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
				present(alert, animated: true, completion: nil)
			}
			do {
				try fetchedResultsController.performFetch()
				tableView.reloadData()
			} catch {
				print("Fetch failed")
			}
		}
	}

	override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
		return false
	}

	override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return true
	}

	override func tableView(_ tableView: UITableView,
							moveRowAt sourceIndexPath: IndexPath,
							to destinationIndexPath: IndexPath) {
		let category = fetchedResultsController.object(at: sourceIndexPath)
		let newSortId = fetchedResultsController.object(at: destinationIndexPath).sortId

		Facade.share.model.changeCategoryOrdering(category, newSortId: newSortId)

		do {
			try fetchedResultsController.performFetch()
			tableView.reloadData()
		} catch {
			print("Fetch failed")
		}

	}

	override func tableView(_ tableView: UITableView,
							targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
							toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
		if sourceIndexPath.section != proposedDestinationIndexPath.section {
			var row = 0
			if sourceIndexPath.section < proposedDestinationIndexPath.section {
				row = self.tableView(tableView, numberOfRowsInSection: sourceIndexPath.section) - 1
			}
			return IndexPath(row: row, section: sourceIndexPath.section)
		}
		return proposedDestinationIndexPath
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! SWCategoryTableViewCell

		let category = fetchedResultsController.object(at: indexPath)

		cell.setup(model: SWCategoryTableViewCellModel(
			title: category.name,
			icon: category.iconImage()
		))

		return cell
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 50
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let category = fetchedResultsController.object(at: indexPath)

		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let controller = storyboard.instantiateViewController(withIdentifier: "AddCategory") as! AddCategoryViewController

		controller.currentUid = category.uid
		navigationController?.pushViewController(controller, animated: true)
	}	

}
