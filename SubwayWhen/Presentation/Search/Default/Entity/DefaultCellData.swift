//
//  DefaultCellData.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/07/04.
//

import Foundation

import RxDataSources

struct DefaultCellData: Equatable, IdentifiableType {
    let title: String
}

extension DefaultCellData {
    var identity: String {
        self.title
    }
}
