//
//  FixInfo.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/29.
//

import Foundation

struct FixInfo: Codable{
    static var saveStation : [SaveStation] = [] {
        didSet{
            let data = try? PropertyListEncoder().encode(self.saveStation)
            UserDefaults.shared.set(data, forKey: "saveStation")
        }
    }
    
    static var saveSetting : SaveSetting =
    SaveSetting() {
        didSet{
            let data = try? PropertyListEncoder().encode(self.saveSetting)
            UserDefaults.shared.set(data, forKey: "saveSetting")
        }
    }
}
