//
//  ReportContentsModalSection.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/08.
//

import Foundation

import RxDataSources

struct ReportContentsModalSection : AnimatableSectionModelType{
    var titleName : String
    var items: [Item]
}

extension ReportContentsModalSection{
    typealias Item =  ReportContentsModalCellData
    typealias Identity = String
    
    var identity: String{
        self.titleName
    }
    
    init(original: ReportContentsModalSection, items: [ReportContentsModalCellData]) {
        self = original
        self.items = items
    }
}
