//
//  DefaultSectionData.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/07/04.
//

import Foundation

import RxDataSources

struct DefaultSectionData: AnimatableSectionModelType {
    let id: String
    var items: [Item]
}

extension DefaultSectionData {
    var identity: String {
        self.id
    }
    
    typealias Item = DefaultCellData
    
    init(original: DefaultSectionData, items: [DefaultCellData]) {
        self = original
        self.items = items
    }
}
