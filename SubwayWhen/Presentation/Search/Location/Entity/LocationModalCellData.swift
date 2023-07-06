//
//  LocationModalCellData.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/07/05.
//

import Foundation

import RxDataSources

struct LocationModalCellData: Equatable, IdentifiableType {
    let id: String
    let name: String
    let line: String
    let distance: String
    
    var lineColorName: String {
        guard self.line != "경의중앙선" else {return "경의선"}
        guard self.line != "에버라인" else {return "용인경전철"}
        
        guard Int(String(self.line.first ?? "A")) != nil else {return self.line}

        var value = self.line
        value.insert("0", at: self.line.startIndex)
        return value
    }
}

extension LocationModalCellData {
    var identity: String {
        self.id
    }
}
