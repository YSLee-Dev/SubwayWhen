//
//  TotalLoadProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/15.
//

import Foundation

import RxSwift

protocol TotalLoadProtocol{
    func totalLiveDataLoad(stations : [SaveStation]) -> Observable<(MainTableViewCellData, Int)>
    func singleLiveDataLoad(requestModel: DetailArrivalDataRequestModel) -> Observable< [RealtimeStationArrival]>
    func korailSchduleLoad(scheduleSearch : ScheduleSearch, isFirst : Bool, isNow : Bool, isWidget: Bool, requestDate: Date) ->  Observable<[ResultSchdule]>
    func seoulScheduleLoad(_ scheduleSearch : ScheduleSearch, isFirst : Bool, isNow : Bool, isWidget: Bool, requestDate: Date) -> Observable<[ResultSchdule]>
    func stationNameSearchReponse(_ stationName : String) -> Observable<SearchStaion>
    func defaultViewListLoad() -> Observable<[String]>
    func vicinityStationsDataLoad(x: Double, y: Double) -> Observable<[VicinityDocumentData]>
    func importantDataLoad() -> Observable<ImportantData>
    func scheduleDataFetchAsyncData(_ scheduleData: Observable<[ResultSchdule]>) async -> [ResultSchdule]
    func sinbundangScheduleLoad(scheduleSearch: ScheduleSearch, isFirst: Bool, isNow: Bool, isWidget: Bool, requestDate: Date) -> Observable<[ResultSchdule]>
}

extension TotalLoadProtocol {
    func korailSchduleLoad(scheduleSearch : ScheduleSearch, isFirst : Bool, isNow : Bool, isWidget: Bool, requestDate: Date = .now) ->  Observable<[ResultSchdule]> {
        self.korailSchduleLoad(scheduleSearch: scheduleSearch, isFirst: isFirst, isNow: isNow, isWidget: isWidget, requestDate: requestDate)
    }
    
    func seoulScheduleLoad(_ scheduleSearch : ScheduleSearch, isFirst : Bool, isNow : Bool, isWidget: Bool, requestDate: Date = .now) -> Observable<[ResultSchdule]> {
        self.seoulScheduleLoad(scheduleSearch, isFirst: isFirst, isNow: isNow, isWidget: isWidget, requestDate: requestDate)
    }
    
    func sinbundangScheduleLoad(scheduleSearch: ScheduleSearch, isFirst: Bool, isNow: Bool, isWidget: Bool, requestDate: Date = .now) -> Observable<[ResultSchdule]> {
        self.sinbundangScheduleLoad(scheduleSearch: scheduleSearch, isFirst: isFirst, isNow: isNow, isWidget: isWidget, requestDate: requestDate)
    }
}
