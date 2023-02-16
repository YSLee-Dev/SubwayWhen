//
//  SettingTableViewCellSection.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/16.
//

import Foundation

import RxDataSources

struct SettingTableViewCellSection : AnimatableSectionModelType{
    var sectionName : String
    var items: [Item]
}
extension SettingTableViewCellSection{
    init(original: SettingTableViewCellSection, items: [SettingTableViewCellData]) {
        self = original
        self.items = items
    }
    
    typealias Item = SettingTableViewCellData
    typealias Identity = String
    
    var identity: String {
        self.sectionName
    }
}

