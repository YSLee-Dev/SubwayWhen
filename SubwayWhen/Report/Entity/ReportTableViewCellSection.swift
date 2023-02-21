//
//  ReportTableViewCellSection.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/21.
//

import Foundation

import RxDataSources

struct ReportTableViewCellSection{
    let sectionName : String
    var items : [Item]
}

extension ReportTableViewCellSection : AnimatableSectionModelType{
    typealias Identity = String
    typealias Item = ReportTableViewCellData
    
    var identity: String{
        self.sectionName
    }
    
    init(original: ReportTableViewCellSection, items: [ReportTableViewCellData]) {
        self = original
        self.items = items
    }
    
}
