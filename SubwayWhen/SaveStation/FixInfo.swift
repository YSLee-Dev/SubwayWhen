//
//  FixInfo.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/29.
//

import Foundation

struct FixInfo : Codable{
    static var saveStation : [SaveStation] = [] {
        didSet{
            let data = try? PropertyListEncoder().encode(self.saveStation)
            UserDefaults.standard.setValue(data, forKey: "saveStation")
        }
    }
}
