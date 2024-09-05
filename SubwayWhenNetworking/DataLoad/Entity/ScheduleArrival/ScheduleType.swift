//
//  ScheduleType.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/12.
//

import Foundation

enum ScheduleType: Equatable{
    case Seoul
    case Korail
    case Shinbundang
    case Unowned
    
    static func lineNumberScheduleType(line: String) -> ScheduleType {
        if line == "신분당선" {
            return .Shinbundang
        } else if  line == "공항철도" || line == "우이신설경전철" || line == "" || line == "경강선" || line == "서해선" || line == "GTX-A" {
            return .Unowned
        } else if line == "경의선" || line == "경춘선" || line == "수인분당선" {
            return .Korail
        } else {
            return .Seoul
        }
    }
}
