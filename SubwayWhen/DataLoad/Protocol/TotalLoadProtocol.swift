//
//  TotalLoadProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/15.
//

import Foundation

import RxSwift

protocol TotalLoadProtocol{
    func totalLiveDataLoad(stations : [SaveStation]) -> Observable<MainTableViewCellData>
    func singleLiveDataLoad(station : String) -> Observable<LiveStationModel>
    func korailSchduleLoad(scheduleSearch : ScheduleSearch, isFirst : Bool, isNow : Bool) ->  Observable<[ResultSchdule]>
    func seoulScheduleLoad(_ scheduleSearch : ScheduleSearch, isFirst : Bool, isNow : Bool) -> Observable<[ResultSchdule]>
}
