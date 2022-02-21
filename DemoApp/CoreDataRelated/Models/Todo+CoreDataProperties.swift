//
//  Todo+CoreDataProperties.swift
//  DemoApp
//
//  Created by Lefteris Mantas on 21/2/22.
//
//

import Foundation
import CoreData


extension Todo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Todo> {
        return NSFetchRequest<Todo>(entityName: "Todo")
    }

    @NSManaged public var completed: Bool
    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var userId: Int64

}

extension Todo : Identifiable {

}
