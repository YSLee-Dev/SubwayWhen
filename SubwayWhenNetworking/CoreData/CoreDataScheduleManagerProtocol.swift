//
//  CoreDataScheduleManagerProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 9/16/24.
//

import Foundation

protocol CoreDataScheduleManagerProtocol {
    func shinbundangScheduleDataSave(to scheduleData: [String: [ShinbundangScheduleModel]], scheduleVersion: Int) -> Bool
    func shinbundangScheduleDataLoad(stationName: String) -> [ShinbundangLineScheduleModel]
}
