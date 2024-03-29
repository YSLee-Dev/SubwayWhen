//
//  ScheduleSearch.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/12/05.
//

import Foundation

struct ScheduleSearch{
    var stationCode : String
    let upDown : String
    let exceptionLastStation : String
    let line : String
    let korailCode : String
    
    var allowScheduleLoad: ScheduleType {
        if  line == "신분당선" || line == "공항철도" || line == "우이신설경전철" || line == "" {
            return .Unowned
        } else if line == "경의선" || line == "경춘선" || line == "수인분당선" {
            return .Korail
        } else {
            return .Seoul
        }
    }
}
