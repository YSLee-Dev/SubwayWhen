//
//  SettingTableViewCellData.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/16.
//

import Foundation

import RxDataSources

struct SettingTableViewCellData : IdentifiableType, Equatable{
    let settingTitle : String
    let defaultData : String
    let inputType : SettingTableViewCellType
    let groupType : SettingTableViewCellGroupType
    
    typealias Identity = String
    
    var identity: String {
        self.settingTitle
    }
}
