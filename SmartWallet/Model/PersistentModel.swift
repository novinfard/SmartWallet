//
//  PersistentModel.swift
//  SmartWallet
//
//  Created by Soheil on 03/04/2018.
//  Copyright © 2018 Soheil Novinfard. All rights reserved.
//

import Foundation
import CoreData

class PersistentModel {
	static let sharedInstance = PersistentModel()
	
	var container: NSPersistentContainer!
	var resultController: NSFetchRequestResult!
	var addRecordModel: AddRecordModel
	
	init() {
//		print("PersistentModel - init")
		addRecordModel = AddRecordModel()
		
		// initialise core data
		container = NSPersistentContainer(name: "WalletModel")
		
		container.loadPersistentStores { (storeDescription, error) in
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
				account.uid = getNewUID()
				
				saveContext()
				
				// pre-defined cateogories import
				let expenseCategoryNames = ["Foods & Drinks", "Groceries", "Transport", "Shopping", "Bills", "Financial Expenses", "Entertainment", "Holidays", "Personal Care", "Family", "Lending", "Housing", "Accommodation", "General"]
				let incomeCategoryNames = ["Salary", "Supports", "Investments", "Gifts", "Copuns", "Rental Income", "Sales", "Interests", "Refunding Debt", "General"]
				
				
				for categoryName in expenseCategoryNames.reversed() {
					let category = Categories(context: self.container.viewContext)
					category.direction = -1
					category.name = categoryName
					category.parent = ""
					category.uid = getNewUID()
					saveContext()
					category.sortId = category.getAutoIncremenet()
					saveContext()
				}
				
				for categoryName in incomeCategoryNames.reversed() {
					let category = Categories(context: self.container.viewContext)
					category.direction = 1
					category.name = categoryName
					category.parent = ""
					category.uid = getNewUID()
					saveContext()
					category.sortId = category.getAutoIncremenet()
					saveContext()
				}
				
				saveContext()
				
				let currentSymbol = NSLocale.current.currencySymbol ?? ""
				UserDefaults.standard.set(currentSymbol, forKey: "currencySymbol")
			}
		}
		catch {
			print ("fetch task failed", error)
		}
		
	}
	
	func getMinMaxDateInRecords() -> (min: Date, max: Date){
		do {
			let fetchRequest : NSFetchRequest<Records> = Records.createFetchRequest()
			let sort = NSSortDescriptor(key: "datetime", ascending: true)
			fetchRequest.sortDescriptors = [sort]
			let authorList: [Records] = try container.viewContext.fetch(fetchRequest)
			return (authorList.first?.datetime ?? Date(), authorList.last?.datetime ?? Date())
		} catch {
			return (Date(), Date())
		}
	}
	
	func getMaxAmountInBudget() -> Double{
		var amount: Double?
		do {
			let fetchRequest : NSFetchRequest<Categories> = Categories.createFetchRequest()
			let sort = NSSortDescriptor(key: "budget", ascending: false)
			fetchRequest.sortDescriptors = [sort]
			let categoriesList: [Categories] = try container.viewContext.fetch(fetchRequest)
			amount = categoriesList.first?.budget
		} catch {
			print(error.localizedDescription)
		}
		
		return amount ?? 0.0
	}
	
	func getNumberOfRecordsInCategory(uid: String) -> Int{
		do {
			let fetchRequest : NSFetchRequest<Records> = Records.createFetchRequest()
			fetchRequest.predicate = NSPredicate(format: "relatedCategory.uid = %@", uid)
			let result: [Records] = try container.viewContext.fetch(fetchRequest)
			return result.count
		} catch {
			print(error.localizedDescription)
			
			return 0
		}
	}
	
	func getOrCreateRecord(uid: String) -> Records{
		guard uid != "" else {
			return Records(context: container.viewContext)
		}
		
		var record: Records?
		do {
			let fetchRequest : NSFetchRequest<Records> = Records.createFetchRequest()
			fetchRequest.predicate = NSPredicate(format: "uid = %@", uid)
			let result: [Records] = try container.viewContext.fetch(fetchRequest)
			record = result.first
		} catch {
			print(error.localizedDescription)
		}
		
		return record ?? Records(context: container.viewContext)
	}
	
	func getRecord(uid: String) -> Records?{
		guard uid != "" else {
			return nil
		}
		
		do {
			let fetchRequest : NSFetchRequest<Records> = Records.createFetchRequest()
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
	
	func getOrCreateCategory(uid: String) -> Categories{
		guard uid != "" else {
			return Categories(context: container.viewContext)
		}
		
		var record: Categories?
		do {
			let fetchRequest : NSFetchRequest<Categories> = Categories.createFetchRequest()
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
			let fetchRequest : NSFetchRequest<Categories> = Categories.createFetchRequest()
			if plusOperaion {
				fetchRequest.predicate = NSPredicate(format: "sortId >= %d and sortId < %d and direction = %d and uid != %@", newSortId, previousSortId, category.direction, category.uid, category.uid)
				print("sortId >= %d and sortId < %d and direction = %d and uid != %@", newSortId, previousSortId, category.direction, category.uid, category.uid)
			} else {
				fetchRequest.predicate = NSPredicate(format: "sortId <= %d and sortId > %d and direction = %d and uid != %@", newSortId, previousSortId, category.direction, category.uid)
				print("sortId <= %d and sortId > %d and direction = %d and uid != %@", newSortId, previousSortId, category.direction, category.uid)
			}
			let sort = NSSortDescriptor(key: "sortId", ascending: true)
			fetchRequest.sortDescriptors = [sort]
			let results: [Categories] = try container.viewContext.fetch(fetchRequest)
			
			if plusOperaion {
				for cat in results {
//					print("\(cat.name) was \(cat.sortId)")
					cat.sortId +=  1
//					print("\(cat.name) is \(cat.sortId) now +")
//					print("")
				}
			} else {
				for cat in results {
//					print("\(cat.name) was \(cat.sortId)")
					cat.sortId -=  1
//					print("\(cat.name) is \(cat.sortId) now -")
//					print("")
				}
			}
		} catch {
			print(error.localizedDescription)
		}
		
		saveContext()
	}
	
	func getTotalMonth(year: Int, month: Int, type: recordType) -> Double {
		do {
			let fetchRequest : NSFetchRequest<Records> = Records.createFetchRequest()
			
			var direction: Int
			if(type == .recordTypeCost) {
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
		return String(Date().timeIntervalSince1970.format(f: ".5"))
	}
	
	func getMonthlyTotalByCategory(year: Int, month: Int, type: recordType) -> Array<(amount: Double, category: Categories)> {
		var output = Array<(amount: Double, category: Categories)>()
		do {
			let fetchRequest = NSFetchRequest<NSDictionary>(entityName:"Records")
			
			var direction: Int
			if(type == .recordTypeCost) {
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
					if let sum =  (result as! NSDictionary)["sumOfAmount"] , let cat =  (result as! NSDictionary)["relatedCategory"] {
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
		
		var amountTotal : Double = 0
		
		// Step 1:
		// - Create the summing expression on the amount attribute.
		// - Name the expression result as 'amountTotal'.
		// - Assign the expression result data type as a Double.
		
		let expression = NSExpressionDescription()
		expression.expression =  NSExpression(forFunction: "sum:", arguments:[NSExpression(forKeyPath: "budget")])
		expression.name = "amountTotal";
		expression.expressionResultType = NSAttributeType.doubleAttributeType
		
		// Step 2:
		// - Create the fetch request for the entity.
		// - Indicate that the fetched properties are those that were
		//   described in `expression`.
		// - Indicate that the result type is a dictionary.
		
		let fetchRequest = NSFetchRequest<NSDictionary>(entityName:"Categories")
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
			let resultMap = results[0] as! [String:Double]
			amountTotal = resultMap["amountTotal"]!
		} catch {
			print("Error when summing amounts: \(error.localizedDescription)")
		}
		
		return amountTotal
	}
	
	func addSampleRecord() {
		let record = Records(context: self.container.viewContext)
		record.amount = drand48() * 20;
		record.datetime = Date()
		record.direction = drand48() > 0.5 ? 1 : -1
		record.note = ""
		record.reported = true
		record.uid = UUID().uuidString
		
		saveContext()
	}
	
	func addSampleCategory() {
		let cateory = Categories(context: Facade.share.model.container.viewContext)
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
