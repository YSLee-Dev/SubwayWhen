//
//  TutorialSectionData.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/09/24.
//

import Foundation

import RxDataSources

struct TutorialSectionData: Equatable {
    let sectionName: String
    var items: [Item]
}

extension TutorialSectionData: AnimatableSectionModelType{
    typealias Item = TutorialCellData
    typealias Identity = String
    
    var identity: String {
        self.sectionName
    }
    
    init(original: TutorialSectionData, items: [TutorialCellData]) {
        self = original
        self.items = items
    }
}
