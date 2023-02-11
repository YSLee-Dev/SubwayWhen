//
//  DetailResultScheduleViewSectionData.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/07.
//

import Foundation

import RxDataSources

struct DetailResultScheduleViewSectionData : AnimatableSectionModelType{
    var sectionName : String
    var hour : Int
    var items : [DetailResultScheduleItem]
}

extension DetailResultScheduleViewSectionData{
    typealias DetailResultScheduleItem = DetailResultScheduleViewCellData
    typealias Identity = String
    
    var identity: String {
        self.sectionName
    }
    
    init(original: DetailResultScheduleViewSectionData, items: [DetailResultScheduleViewCellData]) {
        self = original
        self.items = items
    }
}
