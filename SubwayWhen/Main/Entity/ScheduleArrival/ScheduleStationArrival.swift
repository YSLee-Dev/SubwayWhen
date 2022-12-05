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
    
    enum CodingKeys : String, CodingKey{
        case startTime = "LEFTTIME"
        case stationCode = "STATION_CD"
        case lastStation = "SUBWAYENAME"
        case upDown = "INOUT_TAG"
    }
}
