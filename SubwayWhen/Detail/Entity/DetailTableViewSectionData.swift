//
//  DetailTableViewSectionData.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/03.
//

import Foundation

import RxSwift
import RxDataSources

struct DetailTableViewSectionData : AnimatableSectionModelType{
    var sectionName : String
    var items: [Item]
}

extension DetailTableViewSectionData{
    typealias Item = DetailTableViewCellData
    typealias Identity = String
    
    var identity: String{
        return self.sectionName
    }
    
    init(original: DetailTableViewSectionData, items: [DetailTableViewCellData]) {
        self = original
        self.items = items
    }
}
