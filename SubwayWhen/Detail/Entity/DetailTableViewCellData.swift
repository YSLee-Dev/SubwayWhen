//
//  DetailTableViewCellData.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/03.
//

import Foundation

import RxSwift
import RxDataSources

struct DetailTableViewCellData : IdentifiableType, Equatable {
    let id : String
    let stationCode : String
    let exceptionLastStation : String
    let subWayId : String
    let upDown : String
    let lineNumber : String
    let useLine : String
    let stationName : String
    let backStationName : String
    let nextStationName : String
}

extension DetailTableViewCellData{
    typealias Identity = String
    
    var identity: String{
        self.id
    }
}
