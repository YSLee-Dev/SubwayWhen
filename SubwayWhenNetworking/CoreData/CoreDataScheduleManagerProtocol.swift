//
//  CoreDataScheduleManagerProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 9/16/24.
//

import Foundation

protocol CoreDataScheduleManagerProtocol {
    func shinbundangScheduleDataSave(to scheduleData: [String: [ShinbundangScheduleModel]], scheduleVersion: String)
    func shinbundangScheduleDataLoad(stationName: String) -> ShinbundangLineScheduleModel?
    func shinbundangScheduleDataRemove(stationName: String)
}
