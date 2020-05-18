//
//  Tag+CoreDataProperties.swift
//  Simple Notes
//
//  Created by Alexander Sherstnev on 5/17/20.
//  Copyright © 2020 Alexander Sherstnev. All rights reserved.
//
//

import Foundation
import CoreData


extension Tag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    @NSManaged public var value: String?

}
