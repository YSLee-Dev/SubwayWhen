//
//  MainModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/21.
//

import Foundation

import RxSwift

protocol MainModelProtocol{
    func congestionDataLoad() -> Observable<Int>
    func totalDataRemove() -> Observable<[MainTableViewCellData]>
    func timeGroup(oneTime : Int, twoTime : Int) -> Observable<SaveStationGroup>
    func arrivalDataLoad(stations : [SaveStation]) -> Observable<MainTableViewCellData>
    func mainSectionDataLoad(_ data : [MainTableViewCellData]) -> [MainTableViewSection]
    func mainCellDataToScheduleData(_ item : MainTableViewCellData) -> ScheduleSearch?
    func scheduleLoad(_ data : ScheduleSearch) ->  Observable<[ResultSchdule]>
    func scheduleDataToMainTableViewCell(data : ResultSchdule, nowData : MainTableViewCellData) -> MainTableViewCellData
}
