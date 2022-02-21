//
//  User+CoreDataProperties.swift
//  DemoApp
//
//  Created by Lefteris Mantas on 21/2/22.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var email: String?
    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var phone: String?
    @NSManaged public var website: String?

}

extension User : Identifiable {

}
