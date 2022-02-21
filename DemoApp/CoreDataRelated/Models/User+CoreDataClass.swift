//
//  User+CoreDataClass.swift
//  DemoApp
//
//  Created by Lefteris Mantas on 17/2/22.
//
//

import Foundation
import CoreData

@objc(User)
public class User: NSManagedObject, Codable {
    enum CodingKeys: CodingKey {
        case id, name ,email, phone, website
     }

    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
          throw DecoderConfigurationError.missingManagedObjectContext
        }

        self.init(context: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int64.self, forKey: .id)
        self.email = try container.decode(String.self, forKey: .email)
        self.phone = try container.decode(String.self, forKey: .phone)
        self.name = try container.decode(String.self, forKey: .name)
        self.website = try container.decode(String.self, forKey: .website)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encode(phone, forKey: .phone)
        try container.encode(website, forKey: .website)

        
      }

}
