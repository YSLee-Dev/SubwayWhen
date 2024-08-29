//
//  DetailSendModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 8/29/24.
//

import Foundation

struct DetailSendModel: Equatable {
    let upDown : String
    let stationName : String
    let lineNumber: String
    let stationCode : String
    var exceptionLastStation : String
    let korailCode : String
}
