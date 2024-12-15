//
//  TotalRealtimeStationArrival.swift
//  SubwayWhenNetworking
//
//  Created by 이윤수 on 12/9/24.
//

import Foundation

struct TotalRealtimeStationArrival:  Equatable, Hashable {
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
    let trainCode : String
    let backStationName: String
    let nextStationName: String
    var nowStateMSG: String
    
    init(realTimeStationArrival: RealtimeStationArrival, backStationName: String, nextStationName: String, nowStateMSG: String) {
        self.upDown = realTimeStationArrival.upDown
        self.arrivalTime = realTimeStationArrival.arrivalTime
        self.previousStation = realTimeStationArrival.previousStation
        self.subPrevious = realTimeStationArrival.subPrevious
        self.code = realTimeStationArrival.code
        self.subWayId = realTimeStationArrival.subWayId
        self.stationName = realTimeStationArrival.stationName
        self.lastStation = realTimeStationArrival.lastStation
        self.lineNumber = realTimeStationArrival.lineNumber
        self.isFast = realTimeStationArrival.isFast
        self.trainCode = realTimeStationArrival.trainCode
        self.backStationName = backStationName
        self.nextStationName = nextStationName
        self.nowStateMSG = nowStateMSG
    }
    
    var detailArraivalViewText: String {
        (self.subPrevious != "" && self.code != "") ? "🚇 \(self.trainCode) 열차(\(self.isFast == "급행" ? "(급)" : "")\(self.lastStation)행) \n \(self.subPrevious)" : "⚠️ 실시간 정보없음"
    }
}
