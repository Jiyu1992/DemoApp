//
//  CoreDataManager.swift
//  DemoApp
//
//  Created by Lefteris Mantas on 20/2/22.
//

import Foundation
import CoreData

class CoreDataManager: NSObject {
    
    static let sharedInstance = CoreDataManager()
    private override init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "DemoApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            
        })
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return container
    }()
    
    lazy var managedContext = self.persistentContainer.viewContext

    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func fetchUsers() -> [User]?{
        
        let fetchRequest = User.fetchRequest()
        var fetchedUsers: [User]
         
        do {
            fetchedUsers = try managedContext.fetch(fetchRequest)
            return fetchedUsers
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    func fetchTodos(ofUser: Int64) -> [Todo]?{
        let fetchRequest = Todo.fetchRequest()
        var fetchedTodos: [Todo]
        let predicate = NSPredicate(format: "userId = %ld", ofUser)
        fetchRequest.predicate = predicate
        do {
            fetchedTodos = try managedContext.fetch(fetchRequest)
            return fetchedTodos
        } catch (let error) {
            print(error.localizedDescription)
            return nil
        }
    }
    
    
}
