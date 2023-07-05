//
//  LocationModalSectionData.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/07/05.
//

import Foundation

import RxDataSources

struct LocationModalSectionData: AnimatableSectionModelType {
    let id: String
    var items: [Item]
}

extension LocationModalSectionData {
    typealias Item = LocationModalCellData
    
    var identity: String {
        self.id
    }
    
    init(original: LocationModalSectionData, items: [LocationModalCellData]) {
        self = original
        self.items = items
    }
}
