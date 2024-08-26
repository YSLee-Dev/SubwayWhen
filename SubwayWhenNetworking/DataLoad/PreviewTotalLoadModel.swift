//
//  PreviewTotalLoadModel.swift
//  SubwayWhenNetworking
//
//  Created by 이윤수 on 8/26/24.
//

import Foundation
import RxSwift
import RxCocoa

/// 24.08 기준 SwiftUI를 이용하는 View는 상세페이지와 일부 설정 modal이기 때문에 이를 제외한 나머지 값은
/// Empty()를 반환하도록 하였습니다.
/// 테스트는 Mock, DummyLoad를 통해서 개별적으로 이루어집니다.

class PreviewTotalLoadModel : TotalLoadProtocol {
    func totalLiveDataLoad(stations: [SaveStation]) -> RxSwift.Observable<(MainTableViewCellData, Int)> {
        .empty()
    }
    
    func singleLiveDataLoad(station: String) -> RxSwift.Observable<LiveStationModel> {
        .empty()
    }
    
    func stationNameSearchReponse(_ stationName: String) -> RxSwift.Observable<SearchStaion> {
        .empty()
    }
    
    func defaultViewListLoad() -> RxSwift.Observable<[String]> {
        .empty()
    }
    
    func vicinityStationsDataLoad(x: Double, y: Double) -> RxSwift.Observable<[VicinityDocumentData]> {
        .empty()
    }
    
    func importantDataLoad() -> RxSwift.Observable<ImportantData> {
        .empty()
    }
    
    func scheduleDataFetchAsyncData(_ scheduleData: RxSwift.Observable<[ResultSchdule]>) async -> [ResultSchdule] {
        []
    }
    
    func scheduleDataFetchAsyncData(type: ScheduleType, searchModel: ScheduleSearch) async -> [ResultSchdule] {
        [
            .init(startTime: "5:00", type: .Seoul, isFast: "", startStation: "수서", lastStation: "독립문"),
            .init(startTime: "5:09", type: .Seoul, isFast: "", startStation: "오금", lastStation: "구파발"),
            .init(startTime: "5:14", type: .Seoul, isFast: "", startStation: "오금", lastStation: "구파발"),
            .init(startTime: "5:17", type: .Seoul, isFast: "", startStation: "오금", lastStation: "대화"),
            .init(startTime: "5:24", type: .Seoul, isFast: "", startStation: "오금", lastStation: "구파발"),
            .init(startTime: "5:29", type: .Seoul, isFast: "", startStation: "오금", lastStation: "대화"),
            .init(startTime: "5:33", type: .Seoul, isFast: "", startStation: "수서", lastStation: "구파발"),
            .init(startTime: "5:40", type: .Seoul, isFast: "", startStation: "수서", lastStation: "대화"),
            .init(startTime: "5:46", type: .Seoul, isFast: "", startStation: "오금", lastStation: "구파발")
        ]
    }
    
    func singleLiveAsyncData(station: String) async -> LiveStationModel {
        .init(realtimeArrivalList: [.init(upDown: "상행", arrivalTime: "3분", previousStation: "고속터미널", subPrevious: "", code: "1", subWayId: "1003", stationName: "교대", lastStation: "구파발", lineNumber: "3", isFast: nil, backStationId: "1003000339", nextStationId: "1003000341", trainCode: "99")])
    }
}
