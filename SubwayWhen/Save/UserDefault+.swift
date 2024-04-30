//
//  UserDefault+.swift
//  SubwayWhen
//
//  Created by 이윤수 on 3/28/24.
//

import Foundation

extension UserDefaults {
    fileprivate static var sharedObject: UserDefaults {
        let groupID = "group.com.yslee.subwaywhen"
        
        return UserDefaults(suiteName: groupID)!
    }
    
    static var shared: UserDefaults {
        if !(UserDefaults.sharedObject.bool(forKey: "userDefaultsMigration")) {
            UserDefaults.standard.dictionaryRepresentation().forEach { (key, value) in
                UserDefaults.sharedObject.set(value, forKey: key)
            }
            UserDefaults.sharedObject.set(true, forKey: "userDefaultsMigration")
        }
        return UserDefaults.sharedObject
    }
}
