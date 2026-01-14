//
//  SaveSetting.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/16.
//

import Foundation

struct SaveSetting : Codable, Equatable {
    var mainCongestionLabel: String
    var mainGroupOneTime: Int
    var mainGroupTwoTime: Int
    var detailAutoReload: Bool
    var detailScheduleAutoTime : Bool
    var liveActivity: Bool
    var searchOverlapAlert: Bool
    var alertGroupOneID: String
    var alertGroupTwoID: String
    var tutorialSuccess: Bool
    var detailVCTrainIcon: String
    var isWeekendNotificationEnabled: Bool
    var mainCongestionBaseStaton: String
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.mainCongestionLabel = try container.decode(String.self, forKey: .mainCongestionLabel)
        self.mainGroupOneTime = try container.decode(Int.self, forKey: .mainGroupOneTime)
        self.mainGroupTwoTime = try container.decode(Int.self, forKey: .mainGroupTwoTime)
        self.detailAutoReload = try container.decode(Bool.self, forKey: .detailAutoReload)
        self.detailScheduleAutoTime = try container.decode(Bool.self, forKey: .detailScheduleAutoTime)
        self.liveActivity = try container.decode(Bool.self, forKey: .liveActivity)
        self.searchOverlapAlert = try container.decode(Bool.self, forKey: .searchOverlapAlert)
        self.alertGroupOneID = try container.decode(String.self, forKey: .alertGroupOneID)
        self.alertGroupTwoID = try container.decode(String.self, forKey: .alertGroupTwoID)
        self.tutorialSuccess = try container.decode(Bool.self, forKey: .tutorialSuccess)
        self.detailVCTrainIcon = try container.decode(String.self, forKey: .detailVCTrainIcon)
        
        do {
            self.isWeekendNotificationEnabled = try container.decode(Bool.self, forKey: .isWeekendNotificationEnabled)
        } catch {
            self.isWeekendNotificationEnabled =  true
        }
        
        do {
            self.mainCongestionBaseStaton = try container.decode(String.self, forKey: .mainCongestionBaseStaton)
        } catch {
            self.mainCongestionBaseStaton =  "강남"
        }
    }
    
    init() {
        self.mainCongestionLabel = "☹️"
        self.mainGroupOneTime =  0
        self.mainGroupTwoTime = 0
        self.detailAutoReload = true
        self.detailScheduleAutoTime = true
        self.liveActivity = true
        self.searchOverlapAlert = true
        self.alertGroupOneID = ""
        self.alertGroupTwoID =  ""
        self.tutorialSuccess = false
        self.detailVCTrainIcon = "🚃"
        self.isWeekendNotificationEnabled =  true
        self.mainCongestionBaseStaton = "강남"
    }
}
