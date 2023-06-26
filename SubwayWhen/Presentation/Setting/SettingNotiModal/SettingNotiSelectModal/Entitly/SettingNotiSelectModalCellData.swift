//
//  SettingNotiSelectModalCellData.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/06/26.
//

import Foundation

import RxDataSources

struct SettingNotiSelectModalCellData: IdentifiableType, Equatable {
    let id : String
    let stationName : String
    let updnLine : String
    let line : String
    let useLine : String
}

extension SettingNotiSelectModalCellData {
    typealias Identity = String
    
    var identity: String {
        self.id
    }
}
