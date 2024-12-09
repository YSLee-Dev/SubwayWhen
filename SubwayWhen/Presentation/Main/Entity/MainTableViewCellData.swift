//
//  MainTableViewCellData.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/12/05.
//

import Foundation

import RxDataSources

struct MainTableViewCellData: Decodable, Hashable {
    let upDown : String
    let arrivalTime : String
    let previousStation : String
    let subPrevious : String
    let code : String
    let subWayId : String
    let stationName : String
    let lastStation : String
    let lineNumber : String
    let isFast : String
    let useLine : String
    let group : String
    let id : String
    let stationCode : String
    var exceptionLastStation : String
    let type : MainTableViewCellType
    var backStationId : String
    var nextStationId : String
    let korailCode : String
    var stateMSG: String
    
    var useTime : String{
        if self.type == .real{
            let time = Int(self.arrivalTime) ?? 0
            let min = Int((time/60))
            
            if min == 0{
                if time == 0{
                    if self.code == "0"{
                        return "곧 도착"
                    }else if self.code == "1"{
                        return "도착"
                    }else if self.code == "2"{
                        return "출발"
                    }else{
                        return self.cutString(cutString: self.subPrevious)
                    }
                }else{
                    return "\(time)초"
                }
            }else{
                return "\(min)분"
            }
        }else{
            return self.subPrevious
        }
        
    }
    
    var useFast : String{
        if self.isFast == "급행"{
            return "(\(self.isFast.first ?? " "))"
        }else if self.isFast == "ITX"{
            return "(ITX)"
        }else{
            return ""
        }
    }
    
    func cutString(cutString : String) -> String{
        guard let sub = cutString.firstIndex(of: "(") else { return  cutString }
        return String(cutString[cutString.startIndex ..< sub])
    }
}

extension MainTableViewCellData : IdentifiableType, Equatable{
    var identity: String {
        return "\(self.id)"
    }
    
    typealias Identity = String
    
}
