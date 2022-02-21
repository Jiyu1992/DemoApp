//
//  Post+CoreDataProperties.swift
//  DemoApp
//
//  Created by Lefteris Mantas on 21/2/22.
//
//

import Foundation
import CoreData


extension Post {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Post> {
        return NSFetchRequest<Post>(entityName: "Post")
    }

    @NSManaged public var body: String?
    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var userId: Int64

}

extension Post : Identifiable {

}
