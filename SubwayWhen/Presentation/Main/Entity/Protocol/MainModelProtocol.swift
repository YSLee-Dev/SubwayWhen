//
//  MainModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/21.
//

import Foundation

import RxSwift

protocol MainModelProtocol{
    func mainTitleLoad() -> Observable<String>
    func congestionDataLoad() -> Observable<Int>
    func timeGroup(oneTime : Int, twoTime : Int, nowHour : Int) -> Observable<SaveStationGroup>
    func arrivalDataLoad(stations: [SaveStation]) -> Observable<(MainTableViewCellData, Int)>
    func createMainTableViewSection(_ data : [MainTableViewCellData]) -> [MainTableViewSection]
    func mainCellDataToScheduleData(_ item : MainTableViewCellData) -> ScheduleSearch?
    func scheduleLoad(_ data : ScheduleSearch) ->  Observable<[ResultSchdule]>
    func scheduleDataToMainTableViewCell(data : ResultSchdule, nowData : MainTableViewCellData) -> MainTableViewCellData
    func headerImportantDataLoad() -> Observable<ImportantData>
    func emptyLiveData(stations: [SaveStation]) -> Observable<[MainTableViewCellData]>
}
