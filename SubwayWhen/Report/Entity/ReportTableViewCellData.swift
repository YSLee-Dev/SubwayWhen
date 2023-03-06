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
    var cellData : String
    let type : ReportTableViewCellType
    var focus : Bool
}

extension ReportTableViewCellData : IdentifiableType, Equatable{
    typealias Identity = String
    
    var identity: String{
        self.cellTitle
    }
}
