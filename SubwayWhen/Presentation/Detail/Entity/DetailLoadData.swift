//
//  DetailLoadData.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/27.
//

import Foundation

struct DetailLoadData : Equatable{
    let upDown : String
    let stationName : String
    let lineNumber : String
    let lineCode: String
    let useLine : String
    let stationCode : String
    var exceptionLastStation : String
    var backStationId : String
    var nextStationId : String
    let korailCode : String
}
