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
    let startStation : String
    let lastStation : String
    let upDown : String
    let line : String
    let weekDay : String
    let isFast : String
    
    enum CodingKeys : String, CodingKey{
        case startTime = "LEFTTIME"
        case stationCode = "FR_CODE"
        case startStation = "SUBWAYSNAME"
        case lastStation = "SUBWAYENAME"
        case upDown = "INOUT_TAG"
        case line = "LINE_NUM"
        case weekDay = "WEEK_TAG"
        case isFast = "EXPRESS_YN"
    }
}
