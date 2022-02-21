//
//  Comment+CoreDataClass.swift
//  DemoApp
//
//  Created by Lefteris Mantas on 17/2/22.
//
//

import Foundation
import CoreData

@objc(Comment)
public class Comment: NSManagedObject,Codable {
    enum CodingKeys: CodingKey {
        case id, body ,email, name, postid
     }

    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
          throw DecoderConfigurationError.missingManagedObjectContext
        }

        self.init(context: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int64.self, forKey: .id)
        self.email = try container.decode(String.self, forKey: .email)
        self.body = try container.decode(String.self, forKey: .body)
        self.name = try container.decode(String.self, forKey: .name)
        self.postId = try container.decode(Int64.self, forKey: .postid)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encode(body, forKey: .body)
        try container.encode(postId, forKey: .postid)

        
      }
}
