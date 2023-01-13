//
//  ScheduleStationArrival.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/12/05.
//

import Foundation

struct ScheduleStationArrival : Decodable{
    let startTime : String
    let stationCode : String
    let lastStation : String
    let upDown : String
    let line : String
    
    enum CodingKeys : String, CodingKey{
        case startTime = "LEFTTIME"
        case stationCode = "FR_CODE"
        case lastStation = "SUBWAYENAME"
        case upDown = "INOUT_TAG"
        case line = "LINE_NUM"
    }
}
