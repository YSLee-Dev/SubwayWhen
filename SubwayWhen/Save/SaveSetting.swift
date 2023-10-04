//
//  SaveSetting.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/16.
//

import Foundation

struct SaveSetting : Codable{
    var mainCongestionLabel : String
    var mainGroupOneTime : Int
    var mainGroupTwoTime : Int
    var detailAutoReload : Bool
    var detailScheduleAutoTime : Bool
    var liveActivity : Bool
    var searchOverlapAlert : Bool
    var alertGroupOneID: String
    var alertGroupTwoID: String
    var tutorialSuccess: Bool
}
