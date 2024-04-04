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
    
    var useLine: String{
        let zeroCut = self.line.replacingOccurrences(of: "0", with: "")
        
        if zeroCut.count < 4 {
            return String(zeroCut[zeroCut.startIndex ..< zeroCut.index(zeroCut.startIndex, offsetBy: zeroCut.count)])
        }else{
            return String(zeroCut[zeroCut.startIndex ..< zeroCut.index(zeroCut.startIndex, offsetBy: 4)])
        }
    }
    
    var widgetUseText: String {
        let group = group == .one ? "출근" : "퇴근"
        let exception = exceptionLastStation == "" ? "" : " (\(exceptionLastStation) 행 제외)"
        return  group + " " +  useLine + " (" + updnLine + ") "  + "\n" + stationName + exception
    }
    
    var allowScheduleLoad: Bool {
        return !(line == "신분당선" || line == "공항철도" || line == "우이신설경전철" || line == "")
    }
}


