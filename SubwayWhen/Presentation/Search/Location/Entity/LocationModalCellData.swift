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
}

extension LocationModalCellData {
    var identity: String {
        self.id
    }
}
