//
//  SaveSetting.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/16.
//

import Foundation

struct SaveSetting : Codable{
    var mainCongestionLabel : String
    var mainGroupTime : Int
    var detailAutoReload : Bool
}
