//
//  ResultSchedule.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/12.
//

import Foundation

struct ResultSchdule: Equatable {
    var startTime : String
    var type : ScheduleType
    var isFast : String
    var startStation : String
    var lastStation : String
    
    var useTime : String{
         if self.type == .Seoul || self.type == .Shinbundang{
            let nowDate = Date()
            let now = Calendar.current
            
            let timeCut = self.startTime.components(separatedBy: ":")
            
             if timeCut.isEmpty || (timeCut.count < 3 && self.type == .Seoul) || (timeCut.count < 2 && self.type == .Shinbundang){
                return "정보없음"
            }
            
             guard let time = Calendar.current.date(from: DateComponents(year: now.component(.year, from: nowDate), month: now.component(.month, from: nowDate), day: now.component(.day, from: nowDate), hour: Int(timeCut[0]), minute: Int(timeCut[1]), second: (self.type == .Seoul ? Int(timeCut[2]) : 0))) else {return ""}
            
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
        if self.type == .Unowned{
            return "정보없음"
        }else if self.type == .Korail{
            var time = self.startTime
            if time != "0", time != "", !(time.contains("없음")){
                let index1 = time.index(time.startIndex, offsetBy: 2)
                
                time.insert(":", at: index1)
            }
          
            return String(time.dropLast(2))
        } else if self.type == .Shinbundang {
            guard let first = Int(String(self.startTime.first ?? "0")) else {return self.startTime}
            if first > 3  { // 신분당선의 시간표는 0시를 24시로 표현하며, 25시(오전 1시) 데이터는 없음
                return "0" + self.startTime
            } else {
                return self.startTime
            }
        } else{
            return String(self.startTime.dropLast(3))
        }
    }
}
