//
//  PreviewTotalLoadTCADependency.swift
//  SubwayWhenNetworking
//
//  Created by 이윤수 on 8/29/24.
//

import Foundation

class PreviewTotalLoadTCADependency: TotalLoadTCADependencyProtocol {
    func scheduleDataFetchAsyncData(searchModel: ScheduleSearch, isDisposable: Bool) async -> [ResultSchdule]  {
        [
            .init(startTime: "05:00:00", type: .Seoul, isFast: "", startStation: "수서", lastStation: "독립문"),
            .init(startTime: "05:09:00", type: .Seoul, isFast: "", startStation: "오금", lastStation: "구파발"),
            .init(startTime: "05:14:00", type: .Seoul, isFast: "", startStation: "오금", lastStation: "구파발"),
            .init(startTime: "05:17:00", type: .Seoul, isFast: "", startStation: "오금", lastStation: "대화"),
            .init(startTime: "05:24:00", type: .Seoul, isFast: "", startStation: "오금", lastStation: "구파발"),
            .init(startTime: "05:29:00", type: .Seoul, isFast: "", startStation: "오금", lastStation: "대화"),
            .init(startTime: "05:33:00", type: .Seoul, isFast: "", startStation: "수서", lastStation: "구파발"),
            .init(startTime: "05:40:00", type: .Seoul, isFast: "", startStation: "수서", lastStation: "대화"),
            .init(startTime: "05:46:00", type: .Seoul, isFast: "", startStation: "오금", lastStation: "구파발")
        ]
    }
    
    func singleLiveAsyncData(requestModel: DetailArrivalDataRequestModel)  async -> [RealtimeStationArrival]{
        [
            .init(upDown: "상행", arrivalTime: "3분", previousStation: "고속터미널", subPrevious: "전전역 도착", code: "3", subWayId: "1003", stationName: "교대", lastStation: "구파발", lineNumber: "3", isFast: nil, backStationId: "1003000339", nextStationId: "1003000341", trainCode: "99"),
            .init(upDown: "상행", arrivalTime: "10분", previousStation: "매봉", subPrevious: "", code: "", subWayId: "1003", stationName: "교대", lastStation: "오금", lineNumber: "3", isFast: nil, backStationId: "1003000339", nextStationId: "1003000341", trainCode: "99")
        ]
    }
    
    func vicinityStationsDataLoad(x: Double, y: Double) async -> [VicinityTransformData] {
        [
            .init(id: "1", name: "교대", line: "03호선", distance: "1000m"),
            .init(id: "2", name: "강남", line: "02호선", distance: "1500m"),
            .init(id: "3", name: "고속터미널", line: "09호선", distance: "2000m"),
            .init(id: "4", name: "사당", line: "04호선", distance: "3000m")
        ]
    }
}
