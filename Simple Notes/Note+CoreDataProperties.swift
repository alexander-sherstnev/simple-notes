//
//  Note+CoreDataProperties.swift
//  Simple Notes
//
//  Created by Alexander Sherstnev on 5/17/20.
//  Copyright © 2020 Alexander Sherstnev. All rights reserved.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        let request = NSFetchRequest<Note>(entityName: "Note")
        return request
    }

    @NSManaged public var content: String?
    @NSManaged public var title: String?
    @NSManaged public var color: Int16
    @NSManaged public var date: Date?
    @NSManaged public var tags: NSSet?

}

// MARK: Generated accessors for tags
extension Note {

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)

}
