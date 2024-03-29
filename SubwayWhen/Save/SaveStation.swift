//
//  SaveStation.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/29.
//

import Foundation

import RxDataSources

struct SaveStation: Codable, Equatable, IdentifiableType {
    let id: String
    let stationName: String
    let stationCode: String
    let updnLine: String
    let line: String
    let lineCode: String
    var group: SaveStationGroup
    let exceptionLastStation: String
    var korailCode: String
    
    var useLine: String{
        let zeroCut = self.line.replacingOccurrences(of: "0", with: "")
        
        if zeroCut.count < 4 {
            return String(zeroCut[zeroCut.startIndex ..< zeroCut.index(zeroCut.startIndex, offsetBy: zeroCut.count)])
        }else{
            return String(zeroCut[zeroCut.startIndex ..< zeroCut.index(zeroCut.startIndex, offsetBy: 4)])
        }
    }
}

extension SaveStation {
    typealias Identity = String
    
    var identity: String {
        self.id
    }
}
