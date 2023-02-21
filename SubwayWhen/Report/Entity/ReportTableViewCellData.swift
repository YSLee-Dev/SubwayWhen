//
//  ReportTableViewCellData.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/21.
//

import Foundation

import RxDataSources

struct ReportTableViewCellData {
    let cellTitle : String
    let type : ReportTableViewCellType
}

extension ReportTableViewCellData : IdentifiableType, Equatable{
    typealias Identity = String
    
    var identity: String{
        self.cellTitle
    }
}
