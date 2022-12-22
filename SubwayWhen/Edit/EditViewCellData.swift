//
//  EditViewCellData.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/12/19.
//

import Foundation

import RxDataSources

struct EditViewCellData : Equatable, IdentifiableType{
    let id : String
    let stationName : String
    let updnLine : String
    let line : String
    let useLine : String
}

extension EditViewCellData{
    typealias Identity = String
    
    var identity: String {
        self.id
    }
}
