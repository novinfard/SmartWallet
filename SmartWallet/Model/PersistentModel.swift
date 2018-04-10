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
	
	init() {
//		print("PersistentModel - init")
		// initialise core data
		container = NSPersistentContainer(name: "WalletModel")
		
		container.loadPersistentStores { (storeDescription, error) in
			self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
			
			if let error = error {
				print("Unsolved error \(error.localizedDescription)")
			}
		}
		
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
