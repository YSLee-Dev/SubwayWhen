//
//  SearchStaion.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/28.
//

import Foundation

struct SearchStaion : Decodable {
    let SearchInfoBySubwayNameService : SearchInfoBySubwayNameService
}

struct SearchInfoBySubwayNameService : Decodable{
    let row : [searchStationInfo]
}

struct searchStationInfo : Decodable, Equatable{
    let stationName : String
    let line : SubwayLineData
    let stationCode : String
    
    enum CodingKeys : String, CodingKey{
        case stationName = "STATION_NM"
        case line = "LINE_NUM"
        case stationCode = "FR_CODE"
    }
}
