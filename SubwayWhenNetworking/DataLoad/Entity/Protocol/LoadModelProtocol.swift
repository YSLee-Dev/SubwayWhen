//
//  LoadModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/01.
//

import Foundation

import RxSwift

protocol LoadModelProtocol : AnyObject{
    func stationArrivalRequest(stationName : String) -> Single<Result<LiveStationModel, URLError>>
    func seoulStationScheduleLoad(scheduleSearch : ScheduleSearch) -> Single<Result<ScheduleStationModel, URLError>>
    func korailTrainNumberLoad() -> Observable<[KorailTrainNumber]>
    func korailSchduleLoad(scheduleSearch : ScheduleSearch) -> Single<Result<KorailHeader, URLError>>
    func stationSearch(station: String) -> Single<Result<SearchStaion,URLError>>
    func defaultViewListRequest() -> Observable<[String]>
    func vicinityStationsLoad(x: Double, y: Double) -> Single<Result<VicinityStationsData,URLError>>
    func importantDataLoad() -> Observable<ImportantData>
    func shinbundangScheduleReqeust(scheduleSearch: ScheduleSearch) -> Observable<[ShinbundangScheduleModel]>
}
