//
//  SettingNotiSelectModalSection.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/06/26.
//

import Foundation

import RxDataSources

struct SettingNotiSelectModalSectionData: AnimatableSectionModelType {
    let id: String
    var items: [item]
}

extension SettingNotiSelectModalSectionData {
    typealias item = SettingNotiSelectModalCellData
    typealias identity = String
    
    var identity: String {
        self.id
    }
    
    init(original: SettingNotiSelectModalSectionData, items: [SettingNotiSelectModalCellData]) {
        self = original
        self.items = items
    }
    
}
