//
//  Categories+CoreDataProperties.swift
//  SmartWallet
//
//  Created by Soheil on 23/01/2018.
//  Copyright © 2018 Soheil Novinfard. All rights reserved.
//
//

import Foundation
import CoreData


extension Categories {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Categories> {
        return NSFetchRequest<Categories>(entityName: "Categories")
    }

    @NSManaged public var direction: Int16
    @NSManaged public var name: String
    @NSManaged public var parent: String
    @NSManaged public var uid: String
    @NSManaged public var relatedRecords: NSSet

}

// MARK: Generated accessors for relatedRecords
extension Categories {

    @objc(addRelatedRecordsObject:)
    @NSManaged public func addToRelatedRecords(_ value: Records)

    @objc(removeRelatedRecordsObject:)
    @NSManaged public func removeFromRelatedRecords(_ value: Records)

    @objc(addRelatedRecords:)
    @NSManaged public func addToRelatedRecords(_ values: NSSet)

    @objc(removeRelatedRecords:)
    @NSManaged public func removeFromRelatedRecords(_ values: NSSet)

}
