//
//  DetailArrivalDataRequestModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 8/29/24.
//

import Foundation

struct DetailArrivalDataRequestModel : Equatable{
    let upDown : String
    let stationName : String
    let line: SubwayLineData
    var exceptionLastStation : String
    var backStationId: String?
    var nextStationId: String?
}
