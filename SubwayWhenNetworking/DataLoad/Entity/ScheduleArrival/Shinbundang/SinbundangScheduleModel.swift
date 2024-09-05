//
//  ShinbundangScheduleModel.swift
//  SubwayWhenNetworking
//
//  Created by 이윤수 on 9/5/24.
//

import Foundation

struct ShinbundangScheduleModel: Equatable, Decodable {
    let endStation: String
    let startStation: String
    let startTime: String
    let stationName: String
    let updown: String
    let week: String
}
