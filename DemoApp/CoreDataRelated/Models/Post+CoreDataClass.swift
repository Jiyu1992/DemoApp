//
//  Post+CoreDataClass.swift
//  DemoApp
//
//  Created by Lefteris Mantas on 17/2/22.
//
//

import Foundation
import CoreData

@objc(Post)
public class Post: NSManagedObject, Codable {
    enum CodingKeys: CodingKey {
        case id, body ,title, userid
     }

    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
          throw DecoderConfigurationError.missingManagedObjectContext
        }

        self.init(context: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int64.self, forKey: .id)
        self.body = try container.decode(String.self, forKey: .body)
        self.title = try container.decode(String.self, forKey: .title)
        self.userId = try container.decode(Int64.self, forKey: .userid)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(body, forKey: .body)
        try container.encode(title, forKey: .title)
        try container.encode(userId, forKey: .userid)

        
      }
}
