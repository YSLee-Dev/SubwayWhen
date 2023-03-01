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
    func saveStationLoad() -> Single<Result<[SaveStation], URLError>>
    func seoulStationScheduleLoad(scheduleSearch : ScheduleSearch) -> Single<Result<ScheduleStationModel, URLError>>
    func TagoStationSchduleLoad(_ scheduleSearch : ScheduleSearch) -> Single<Result<TagoSchduleStation, URLError>>
}
