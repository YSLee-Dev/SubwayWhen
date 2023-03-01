//
//  ResultVCCellData.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/12/14.
//

import Foundation

import RxDataSources

struct ResultVCCellData{
    let stationName : String
    let lineNumber : String
    let stationCode : String
    let useLine : String
    let lineCode : String
}

extension ResultVCCellData : IdentifiableType, Equatable{
    typealias Identity = String
    
    var identity: String {
        "\(self.stationCode)\(self.lineNumber)"
    }
}
