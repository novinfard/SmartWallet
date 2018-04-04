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
		print("PersistentModel - init")
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
			}
		}
		catch {
			print ("fetch task failed", error)
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
}
