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
    
    func singleLiveAsyncData(requestModel: DetailArrivalDataRequestModel) async ->[TotalRealtimeStationArrival] {
        let realTime = RealtimeStationArrival(upDown: "하행", arrivalTime: "3분", previousStation: "고속터미널", subPrevious: "전전역 도착", code: "3", subWayId: "1003", stationName: "교대", lastStation: "구파발", lineNumber: "3", isFast: nil, backStationId: "1003000339", nextStationId: "1003000341", trainCode: "1")
        return [
            .init(realTimeStationArrival:  realTime, backStationName: "고속터미널", nextStationName: "남부터미널", nowStateMSG: realTime.useState)
        ]
    }
    
    func vicinityStationsDataLoad(x: Double, y: Double) async -> [VicinityTransformData] {
        [
            .init(id: "1", name: "교대", line: "3호선", distance: "1000m"),
            .init(id: "2", name: "강남", line: "2호선", distance: "1500m"),
            .init(id: "3", name: "고속터미널", line: "9호선", distance: "2000m"),
            .init(id: "4", name: "사당", line: "4호선", distance: "3000m")
        ]
    }
    
    func defaultViewListLoad() async -> [String] {
        [
            "강남", "교대", "선릉", "삼성", "을지로3가", "종각", "홍대입구", "잠실", "명동", "여의도", "가산디지털단지", "판교"
        ]
    }
    
    func stationNameSearchReponse(_ stationName : String) async -> [searchStationInfo] {
        return [
            .init(stationName: "논현", line:.seven, stationCode: "732"),
            .init(stationName: "논현", line: .shinbundang, stationCode: "D05"),
            .init(stationName: "신논현", line: .nine, stationCode: "925"),
            .init(stationName: "신논현", line: .shinbundang, stationCode: "D06"),
        ]
    }
    
    func searchQueryRecommendListLoad() async -> [SearchQueryRecommendData] {
        return [
            .init(queryName: "가디", stationName: "가산디지털단지", line: "1, 7"),
            .init(queryName: "구디", stationName: "구로디지털단지", line: "1, 7"),
            .init(queryName: "디엠시", stationName: "디지털미디어시티", line: "1, 7")
        ]
    }

    func realtimePositionLoad(subwayLine: SubwayLineData) async -> [RealtimeTrainPosition] {
        switch subwayLine {
        case .two:
            return [
                .init(subwayId: "1002", subwayNm: "2호선", statnId: "1002000216", statnNm: "강남", trainNo: "2001", lastRecptnDt: "", recptnDt: "", updnLine: "0", statnTid: "1002000236", statnTnm: "신사", trainSttus: "1", directAt: "0", lstcarAt: "0"),
                .init(subwayId: "1002", subwayNm: "2호선", statnId: "1002000222", statnNm: "삼성", trainNo: "2002", lastRecptnDt: "", recptnDt: "", updnLine: "0", statnTid: "1002000236", statnTnm: "신사", trainSttus: "2", directAt: "0", lstcarAt: "0")
            ]
        default:
            return []
        }
    }

    func stationIdList(subwayLine: SubwayLineData) -> [DetailStationId] {
        switch subwayLine {
        case .two:
            return [
                .init(lineId: "1002", stationId: "1002000214", stationName: "교대"),
                .init(lineId: "1002", stationId: "1002000216", stationName: "강남"),
                .init(lineId: "1002", stationId: "1002000218", stationName: "역삼"),
                .init(lineId: "1002", stationId: "1002000220", stationName: "선릉"),
                .init(lineId: "1002", stationId: "1002000222", stationName: "삼성"),
            ]
        default:
            return []
        }
    }
}
