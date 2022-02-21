//
//  Extensions.swift
//  DemoApp
//
//  Created by Lefteris Mantas on 16/2/22.
//

import Foundation
import UIKit
import Network


enum DecoderConfigurationError: Error {
  case missingManagedObjectContext
}


extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
    
}

extension UICollectionViewCell {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}
extension UIViewController {
//    func setUpNetworkMonitor(monitor: NWPathMonitor){
//        monitor.pathUpdateHandler = { path in
//            if path.status == .satisfied {
//                NotificationCenter.default.post(name: .networkStatusChanged, object: path.status, userInfo: ["status":"connected"])
//            } else {
//                NotificationCenter.default.post(name: .networkStatusChanged, object: path.status, userInfo: ["status":"disconnected"])
//            }
//        }
//    }
}


extension Notification.Name {
    static let isSyncing = Notification.Name("isSyncing")
    static let hasEndedSync = Notification.Name("hasEndedSync")
    static let hasEndedSyncWithError = Notification.Name("hasEndedSyncWithError")
    static let networkStatusChanged = Notification.Name("networkStatusChanged")
  
}
