//
//  RealtimeStationArrival.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/30.
//

import Foundation

struct RealtimeStationArrival : Decodable{
    let upDown : String
    let arrivalTime : String
    let previousStation : String
    let subPrevious : String
    let code : String
    let subWayId : String
    let stationName : String
    let lastStation : String
    let lineNumber : String?
    let isFast : String?
    let useLine : String?
    let group : String?
    let id : String?
    
    enum CodingKeys : String, CodingKey{
        case upDown = "updnLine"
        case arrivalTime = "barvlDt"
        case previousStation = "arvlMsg3"
        case subPrevious = "arvlMsg2"
        case code = "arvlCd"
        case subWayId = "subwayId"
        case lastStation = "bstatnNm"
        case stationName = "statnNm"
        case lineNumber = "lineNumber"
        case isFast = "btrainSttus"
        case useLine = "useLine"
        case group = "group"
        case id = "id"
    }
    
    
    var useCode : String{
        switch code {
        case "0":
            return "진입"
        case "1":
            return "도착"
        case "2":
            return "출발"
        case "3":
            return "출발"
        case "4":
            return "진입"
        case "5":
            return "도착"
        case "99":
            return "부근"
        default:
            return ""
        }
    }
    
    var useTime : String{
        let time = Int(self.arrivalTime) ?? 0
        let min = Int((time/60))
        
        if min == 0{
            if time == 0{
                return self.cutString(cutString: self.subPrevious)
            }else{
                return "\(time)초"
            }
        }else{
            return "\(min)분"
        }
    }
    
    var useFast : String{
        guard let fast = self.isFast else {return ""}
        return "(\(fast.first ?? " "))"
    }
    
    func cutString(cutString : String) -> String{
        guard let sub = cutString.firstIndex(of: "(") else { return  cutString }
        return String(cutString[cutString.startIndex ..< sub])
    }
}
