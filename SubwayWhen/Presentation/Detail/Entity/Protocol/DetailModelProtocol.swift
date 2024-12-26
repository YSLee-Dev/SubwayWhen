//
//  DetailModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/22.
//

import Foundation

import RxSwift

protocol DetailModelProtocol{
    func nextAndBackStationSearch(backId : String, nextId : String) -> [String]
    func mainCellDataToScheduleSearch(_ item : DetailLoadData) -> ScheduleSearch
    func mainCellDataToDetailSection(_ data : DetailLoadData) -> [DetailTableViewSectionData]
    func scheduleLoad(_ data : ScheduleSearch) -> Observable<[ResultSchdule]>
    func arrvialDataLoad(_ station : String) -> Observable<[RealtimeStationArrival]>
    func arrivalDataMatching(station : DetailLoadData, arrivalData : [RealtimeStationArrival]) -> [RealtimeStationArrival]
    func scheduleSort(_ scheduleList : [ResultSchdule]) -> [ResultSchdule]
}
