//
//  Repository.swift
//  Simple Notes
//
//  Created by Alexander Sherstnev on 5/17/20.
//  Copyright © 2020 Alexander Sherstnev. All rights reserved.
//

import UIKit
import CoreData

struct Repository {
    static let context: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        let persistentContainer = appDelegate.persistentContainer
        return persistentContainer.viewContext
    }()
    
    static func retrieveTags() -> [Tag] {
        do {
            let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
            let result = try context.fetch(fetchRequest)
            
            return result
        } catch let error {
            print("Could not fetch: \(error.localizedDescription)")
            return []
        }
    }
    
    static func retriveNotes() -> [Note] {
        do {
            let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "color", ascending: false),
                                            NSSortDescriptor(key: "date", ascending: false)]
            let result = try context.fetch(fetchRequest)
            
            return result
        } catch let error {
            print("Could not fetch: \(error.localizedDescription)")
            return []
        }
    }
    
    static func save() {
        do {
            try context.save()
        } catch let error {
            print("Could not save: \(error.localizedDescription)")
        }
    }
}
