//
//  SaveStation.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/29.
//

import Foundation

struct SaveStation: Codable, Equatable {
    let id: String
    let stationName: String
    let stationCode: String
    let updnLine: String
    let line: String
    let lineCode: String
    var group: SaveStationGroup
    let exceptionLastStation: String
    var korailCode: String
    
    var subwayLineData: SubwayLineData {
        SubwayLineData(subwayId: lineCode)
    }
    
    var widgetUseText: String {
        let group = group == .one ? "출근" : "퇴근"
        let exception = exceptionLastStation == "" ? "" : " (\(exceptionLastStation) 행 제외)"
        return  group + " " +  subwayLineData.useLine + " (" + updnLine + ") "  + "\n" + stationName + exception
    }
}
