//
//  RealtimeStationArrival.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/30.
//

import Foundation

struct RealtimeStationArrival : Decodable, Equatable, Hashable {
    let upDown : String
    let arrivalTime : String
    let previousStation : String?
    let subPrevious : String
    let code : String
    let subWayId : String
    let stationName : String
    let lastStation : String
    let lineNumber : String?
    let isFast : String?
    let backStationId : String
    let nextStationId : String
    let trainCode : String
    
    enum CodingKeys : String, CodingKey{
        case upDown = "updnLine"
        case arrivalTime = "barvlDt"
        case previousStation = "arvlMsg3"
        case subPrevious = "arvlMsg2"
        case code = "arvlCd"
        case subWayId = "subwayId"
        case lastStation = "bstatnNm"
        case stationName = "statnNm"
        case lineNumber = "lineNumber"
        case isFast = "btrainSttus"
        case backStationId = "statnFid"
        case nextStationId = "statnTid"
        case trainCode = "btrainNo"
    }
    
    var detailArraivalViewText: String {
        (self.subPrevious != "" && self.code != "") ? "🚇 \(self.trainCode) 열차(\(self.lastStation)행) \n \(self.subPrevious)" : "⚠️ 실시간 정보없음"
    }
}
