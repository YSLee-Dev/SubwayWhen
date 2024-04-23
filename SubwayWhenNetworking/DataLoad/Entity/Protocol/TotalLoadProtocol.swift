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
    func singleLiveDataLoad(station : String) -> Observable<LiveStationModel>
    func korailSchduleLoad(scheduleSearch : ScheduleSearch, isFirst : Bool, isNow : Bool, isWidget: Bool) ->  Observable<[ResultSchdule]>
    func seoulScheduleLoad(_ scheduleSearch : ScheduleSearch, isFirst : Bool, isNow : Bool, isWidget: Bool) -> Observable<[ResultSchdule]>
    func stationNameSearchReponse(_ stationName : String) -> Observable<SearchStaion>
    func defaultViewListLoad() -> Observable<[String]>
    func vicinityStationsDataLoad(x: Double, y: Double) -> Observable<[VicinityDocumentData]>
    func importantDataLoad() -> Observable<ImportantData>
    func scheduleDataFetchAsyncData(_ scheduleData: Observable<[ResultSchdule]>) async -> [ResultSchdule]
}
