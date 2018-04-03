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
	var container: NSPersistentContainer!
	var resultController: NSFetchRequestResult!
	
	init() {
		// initialise core data
		container = NSPersistentContainer(name: "WalletModel")
		
		container.loadPersistentStores { (storeDescription, error) in
			self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
			
			if let error = error {
				print("Unsolved error \(error.localizedDescription)")
			}
		}
		
		do {
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
