//
//  SaveStation.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/29.
//

import Foundation

struct SaveStation : Codable{
    let id : String
    let stationName : String
    let updnLine : String
    let line : String
    let lineCode : String
    let group : SaveStationGroup
    let exceptionLastStation : String
    
    var useLine: String{
        let zeroCut = self.line.replacingOccurrences(of: "0", with: "")
        
        if zeroCut.count < 4 {
            return String(zeroCut[zeroCut.startIndex ..< zeroCut.index(zeroCut.startIndex, offsetBy: zeroCut.count)])
        }else{
            return String(zeroCut[zeroCut.startIndex ..< zeroCut.index(zeroCut.startIndex, offsetBy: 4)])
        }
    }
}
