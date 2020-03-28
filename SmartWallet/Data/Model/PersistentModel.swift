//
//  PersistentModel.swift
//  SmartWallet
//
//  Created by Soheil on 03/04/2018.
//  Copyright © 2018 Soheil Novinfard. All rights reserved.
//

import Foundation
import CoreData

// swiftlint:disable type_body_length
// swiftlint:disable file_length
class PersistentModel {
	static let sharedInstance = PersistentModel()

	var container: NSPersistentContainer!
	var resultController: NSFetchRequestResult!
	var addRecordModel: AddRecordModel

	init() {
		addRecordModel = AddRecordModel()

		// initialise core data
		container = NSPersistentContainer(name: "WalletModel")

		container.loadPersistentStores { (_, error) in
			self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

			if let error = error {
				print("Unsolved error \(error.localizedDescription)")
			}
		}

		print(NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).last! as String)

		importInitialData()
	}

	func importInitialData() {
		do {
			let fetchRequest: NSFetchRequest<Accounts> = Accounts.createFetchRequest()
			let result = try container.viewContext.fetch(fetchRequest)

			// luncdhing data initialisation
			if result.count == 0 {
				// add a default account
				let account = Accounts(context: self.container.viewContext)
				account.currency = "£"
				account.initial = 0
				account.name = "Default Account"
				account.uid = getNewUID()

				saveContext()

				for item in SWCategoryData.list {
					let category = Categories(context: self.container.viewContext)
					category.direction = Int16(item.type.direction)
					category.name = item.title
					category.generalId = item.identifier
					category.icon = item.icon
					category.parent = ""
					category.uid = getNewUID()
					saveContext()
					category.sortId = category.getAutoIncremenet()
					saveContext()
				}

				saveContext()

				self.setupDefaultCurrency()
			}
		} catch {
			print ("fetch task failed", error)
		}

	}

	private func setupDefaultCurrency() {
		let currencyList = Currency().loadEveryCountryWithCurrency()
		let systemSymbol = NSLocale.current.currencySymbol ?? ""

		var symbol = "£"
		if currencyList.contains(where: { $0.currencySymbol == systemSymbol }) {
			symbol = systemSymbol
		}
		NSLocale.setupDefaultCurrency(symbol: symbol)
	}

	func getMinMaxDateInRecords() -> (min: Date, max: Date) {
		do {
			let fetchRequest: NSFetchRequest<Records> = Records.createFetchRequest()
			let sort = NSSortDescriptor(key: "datetime", ascending: true)
			fetchRequest.sortDescriptors = [sort]
			let authorList: [Records] = try container.viewContext.fetch(fetchRequest)
			return (authorList.first?.datetime ?? Date(), authorList.last?.datetime ?? Date())
		} catch {
			return (Date(), Date())
		}
	}

	func getMaxAmountInBudget() -> Double {
		var amount: Double?
		do {
			let fetchRequest: NSFetchRequest<Categories> = Categories.createFetchRequest()
			let sort = NSSortDescriptor(key: "budget", ascending: false)
			fetchRequest.sortDescriptors = [sort]
			let categoriesList: [Categories] = try container.viewContext.fetch(fetchRequest)
			amount = categoriesList.first?.budget
		} catch {
			print(error.localizedDescription)
		}

		return amount ?? 0.0
	}

	func getNumberOfRecordsInCategory(uid: String) -> Int {
		do {
			let fetchRequest: NSFetchRequest<Records> = Records.createFetchRequest()
			fetchRequest.predicate = NSPredicate(format: "relatedCategory.uid = %@", uid)
			let result: [Records] = try container.viewContext.fetch(fetchRequest)
			return result.count
		} catch {
			print(error.localizedDescription)

			return 0
		}
	}

	func getOrCreateRecord(uid: String) -> Records {
		guard uid != "" else {
			return Records(context: container.viewContext)
		}

		var record: Records?
		do {
			let fetchRequest: NSFetchRequest<Records> = Records.createFetchRequest()
			fetchRequest.predicate = NSPredicate(format: "uid = %@", uid)
			let result: [Records] = try container.viewContext.fetch(fetchRequest)
			record = result.first
		} catch {
			print(error.localizedDescription)
		}

		return record ?? Records(context: container.viewContext)
	}

	func getRecord(uid: String) -> Records? {
		guard uid != "" else {
			return nil
		}

		do {
			let fetchRequest: NSFetchRequest<Records> = Records.createFetchRequest()
			fetchRequest.predicate = NSPredicate(format: "uid = %@", uid)
			let result: [Records] = try container.viewContext.fetch(fetchRequest)
			if result.count > 0 {
				return result.first
			}
		} catch {
			print(error.localizedDescription)
		}
		return nil
	}

	func getOrCreateCategory(uid: String) -> Categories {
		guard uid != "" else {
			return Categories(context: container.viewContext)
		}

		var record: Categories?
		do {
			let fetchRequest: NSFetchRequest<Categories> = Categories.createFetchRequest()
			fetchRequest.predicate = NSPredicate(format: "uid = %@", uid)
			let result: [Categories] = try container.viewContext.fetch(fetchRequest)
			record = result.first
		} catch {
			print(error.localizedDescription)
		}

		return record ?? Categories(context: container.viewContext)
	}

	func changeCategoryOrdering(_ category: Categories, newSortId: Int64) {
		guard newSortId != category.sortId else {
			return
		}
		let previousSortId = category.sortId

		print("previousSort \(previousSortId), newSort \(newSortId)")

		var plusOperaion = true
		if newSortId >= category.sortId {
			plusOperaion = false
		}

		category.sortId = newSortId
		saveContext()

		do {
			let fetchRequest: NSFetchRequest<Categories> = Categories.createFetchRequest()
			if plusOperaion {
				fetchRequest.predicate = NSPredicate(
					format: "sortId >= %d and sortId < %d and direction = %d and uid != %@",
					newSortId, previousSortId,
					category.direction,
					category.uid,
					category.uid)
			} else {
				fetchRequest.predicate = NSPredicate(
					format: "sortId <= %d and sortId > %d and direction = %d and uid != %@",
					newSortId,
					previousSortId,
					category.direction,
					category.uid)
			}
			let sort = NSSortDescriptor(key: "sortId", ascending: true)
			fetchRequest.sortDescriptors = [sort]
			let results: [Categories] = try container.viewContext.fetch(fetchRequest)

			if plusOperaion {
				for cat in results {
					cat.sortId +=  1
				}
			} else {
				for cat in results {
					cat.sortId -=  1
				}
			}
		} catch {
			print(error.localizedDescription)
		}

		saveContext()
	}

	func getTotalMonth(year: Int, month: Int, type: RecordType) -> Double {
		do {
			let fetchRequest: NSFetchRequest<Records> = Records.createFetchRequest()

			var direction: Int
			if type == .cost {
				direction = -1
			} else {
				direction = 1
			}

			fetchRequest.predicate = NSPredicate(format: "year = %d and month = %d and direction = %d", year, month, direction)
			let recordsList: [Records] = try container.viewContext.fetch(fetchRequest)
			let recordArray = recordsList as NSArray
			return recordArray.value(forKeyPath: "@sum.amount") as! Double
		} catch {

		}

		return 0
	}

	func getNewUID() -> String {
		return String(Date().timeIntervalSince1970.format(formatString: ".5"))
	}

	func getMonthlyTotalByCategory(year: Int, month: Int, type: RecordType) -> [(amount: Double, category: Categories)] {
		var output = [(amount: Double, category: Categories)]()
		do {
			let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Records")

			var direction: Int
			if type == .cost {
				direction = -1
			} else {
				direction = 1
			}
			fetchRequest.predicate = NSPredicate(format: "year = %d and month = %d and direction = %d", year, month, direction)
			fetchRequest.resultType = .dictionaryResultType

			let sumExpression = NSExpression(format: "sum:(amount)")
			let sumED = NSExpressionDescription()
			sumED.expression = sumExpression
			sumED.name = "sumOfAmount"
			sumED.expressionResultType = .doubleAttributeType
			fetchRequest.propertiesToFetch = ["relatedCategory", sumED]

			fetchRequest.propertiesToGroupBy = ["relatedCategory"]
			let sort = NSSortDescriptor(key: "relatedCategory", ascending: false)
			fetchRequest.sortDescriptors = [sort]

			let recordsList = try container.viewContext.fetch(fetchRequest) as NSArray?

			if let results = recordsList {
				for result in results {
					if let sum =  (result as! NSDictionary)["sumOfAmount"], let cat =  (result as! NSDictionary)["relatedCategory"] {
						let sumDoulbe = sum as! Double

						let catId = cat as! NSManagedObjectID
						let categoryObject: Categories = Facade.share.model.container.viewContext.object(with: catId) as! Categories

						output.append((amount: sumDoulbe, category: categoryObject))
					}
				}
			}
			output = output.sorted(by: {$0.amount > $1.amount})
			return output

		} catch {

		}

		return output
	}

	func getTotalBudget() -> Double {

		var amountTotal: Double = 0

		// Step 1:
		// - Create the summing expression on the amount attribute.
		// - Name the expression result as 'amountTotal'.
		// - Assign the expression result data type as a Double.

		let expression = NSExpressionDescription()
		expression.expression =  NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "budget")])
		expression.name = "amountTotal"
		expression.expressionResultType = NSAttributeType.doubleAttributeType

		// Step 2:
		// - Create the fetch request for the entity.
		// - Indicate that the fetched properties are those that were
		//   described in `expression`.
		// - Indicate that the result type is a dictionary.

		let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Categories")
		fetchRequest.propertiesToFetch = [expression]
		fetchRequest.resultType = .dictionaryResultType

		// Step 3:
		// - Execute the fetch request which returns an array.
		// - There will only be one result. Get the first array
		//   element and assign to 'resultMap'.
		// - The summed amount value is in the dictionary as
		//   'amountTotal'. This will be summed value.

		do {
			let results = try container.viewContext.fetch(fetchRequest)
			let resultMap = results[0] as! [String: Double]
			amountTotal = resultMap["amountTotal"]!
		} catch {
			print("Error when summing amounts: \(error.localizedDescription)")
		}

		return amountTotal
	}

	func addSampleData(quantity: Int = 100) {
		// fetch categories
		let categoryRequest: NSFetchRequest<Categories> = Categories.createFetchRequest()
		guard let categories: [Categories] = try? container.viewContext.fetch(categoryRequest) else {
			return
		}

		// setup budget of cateogries
		categories.forEach {
			guard $0.direction == -1 else { return }
			let random = Int.random(in: 20 ... 200)
			let budget = round(Double(random / 10)) * 10
			$0.budget = budget
		}
		saveContext()

		// add records
		for _ in 0 ... quantity {
			guard let cat = categories.randomElement() else {
				return
			}

			let record = Records(context: self.container.viewContext)
			record.amount = drand48() * 20
			record.datetime = Date.randomDate(range: 60)
			record.direction = cat.direction
			record.note = ""
			record.reported = true
			record.uid = UUID().uuidString
			record.relatedCategory = cat
		}
		saveContext()
	}

	func addSampleRecord() {
		let record = Records(context: self.container.viewContext)
		record.amount = drand48() * 20
		record.datetime = Date()
		record.direction = Bool.random() ? 1 : -1
		record.note = ""
		record.reported = true
		record.uid = UUID().uuidString

		saveContext()
	}

	func addSampleCategory() {
		let cateory = Categories(context: Facade.share.model.container.viewContext)
		cateory.name = "Test " + UUID().uuidString.prefix(5)
		cateory.direction = Bool.random() ? 1 : -1
		cateory.uid = UUID().uuidString

		saveContext()
	}

	func updateGeneralCategoriesIfNeeded() {
		let fetchRequest: NSFetchRequest<Categories> = Categories.createFetchRequest()
		fetchRequest.predicate = NSPredicate(format: "icon = nil OR icon = ''")
		if let results: [Categories] = try? container.viewContext.fetch(fetchRequest) {
			let allDefaultCats = SWCategoryData.list
			for category in results {
				if let relatedCat = allDefaultCats.first(where: { $0.title == category.name }) {
					category.generalId = relatedCat.identifier
					category.icon = relatedCat.icon
				}
			}
			saveContext()
		}

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

	func purgeAllData() {
		let uniqueNames = container.managedObjectModel.entities.compactMap({ $0.name })

		uniqueNames.forEach { (name) in
			let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
			let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
			do {
				try container.viewContext.execute(batchDeleteRequest)
			} catch {
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}

	func resetDefaults() {
		let defaults = UserDefaults.standard
		let dictionary = defaults.dictionaryRepresentation()
		dictionary.keys.forEach { key in
			defaults.removeObject(forKey: key)
		}
	}
}

extension NSManagedObject {
	func shallowCopy() -> NSManagedObject? {
		guard let context = managedObjectContext, let entityName = entity.name else { return nil }
		let copy = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
		let attributes = entity.attributesByName
		for (attrKey, _) in attributes {
			copy.setValue(value(forKey: attrKey), forKey: attrKey)
		}
		return copy
	}
}

enum RecordType {
	case cost
	case income
	case all
}
