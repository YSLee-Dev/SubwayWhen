//
//  ResultSchedule.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/12.
//

import Foundation

struct ResultSchdule{
    var startTime : String
    var type : ScheduleType
    var isFast : String
    var startStation : String
    var lastStation : String
    
    var useTime : String{
        if self.type == .Seoul{
            let nowDate = Date()
            let now = Calendar.current
            
            let timeCut = self.startTime.components(separatedBy: ":")
            
            if timeCut.isEmpty || timeCut.count < 3{
                return "정보없음"
            }
            
            guard let time = Calendar.current.date(from: DateComponents(year: now.component(.year, from: nowDate), month: now.component(.month, from: nowDate), day: now.component(.day, from: nowDate), hour: Int(timeCut[0]), minute: Int(timeCut[1]), second: Int(timeCut[2]))) else {return ""}
            
            let minuteToScound = Int(time.timeIntervalSinceNow)/60
            
            return "\(minuteToScound)분"
        }else if self.type == .Korail{
            if startTime != "0", !(startTime.contains("없음")), startTime != ""{
                let nowDate = Date()
                let now = Calendar.current
                
                let time = self.startTime
                let hour = time.index(time.startIndex, offsetBy: 1)
                let hourEnd = time.index(time.startIndex, offsetBy: 2)
                let minute = time.index(time.startIndex, offsetBy: 3)
                let minuteEnd = time.index(time.startIndex, offsetBy: 4)
                let second = time.index(time.startIndex, offsetBy: 5)
                
                guard let fixTime = Calendar.current.date(from: DateComponents(year: now.component(.year, from: nowDate), month: now.component(.month, from: nowDate), day: now.component(.day, from: nowDate), hour: Int(time[...hour]), minute: Int(time[hourEnd ... minute]), second: Int(time[minuteEnd...second]))) else {return ""}
                
                
                let secondToMinute = String(Int(fixTime.timeIntervalSinceNow)/60)
                
                return "\(secondToMinute)분"
            }else{
                return "정보없음"
            }
        }else{
            return "정보없음"
        }
    }
    
    var useArrTime : String{
        if self.type == .Korail{
            var time = self.startTime
            if time != "0", time != "", !(time.contains("없음")){
                let index1 = time.index(time.startIndex, offsetBy: 2)
                let index2 = time.index(time.startIndex, offsetBy: 5)
                
                time.insert(":", at: index1)
                time.insert(":", at: index2)
            }
          
            return time
        }else{
            return self.startTime
        }
    }
}
