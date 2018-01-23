//
//  Records+CoreDataProperties.swift
//  SmartWallet
//
//  Created by Soheil on 23/01/2018.
//  Copyright © 2018 Soheil Novinfard. All rights reserved.
//
//

import Foundation
import CoreData


extension Records {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Records> {
        return NSFetchRequest<Records>(entityName: "Records")
    }

    @NSManaged public var amount: Double
    @NSManaged public var datetime: NSDate
    @NSManaged public var direction: Int16
    @NSManaged public var note: String
    @NSManaged public var reported: Bool
    @NSManaged public var uid: String
    @NSManaged public var relatedAccount: Accounts
    @NSManaged public var relatedCategory: Categories

}
