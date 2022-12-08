//
//  ScheduleStationArrival.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/12/05.
//

import Foundation

struct ScheduleStationArrival : Decodable{
    let startTime : String
    let stationCode : String
    let lastStation : String
    let upDown : String
    let line : String
    
    enum CodingKeys : String, CodingKey{
        case startTime = "LEFTTIME"
        case stationCode = "FR_CODE"
        case lastStation = "SUBWAYENAME"
        case upDown = "INOUT_TAG"
        case line = "LINE_NUM"
    }
    
    var scheduleTime : String{
        let nowDate = Date()
        let now = Calendar.current
        
        let timeCut = self.startTime.components(separatedBy: ":")
        
        guard let time = Calendar.current.date(from: DateComponents(year: now.component(.year, from: nowDate), month: now.component(.month, from: nowDate), day: now.component(.day, from: nowDate), hour: Int(timeCut[0]), minute: Int(timeCut[1]), second: Int(timeCut[2]))) else {return ""}
        
        let minuteToScound = Int(time.timeIntervalSinceNow)/60
        
        return "\(minuteToScound)"
    }
}
