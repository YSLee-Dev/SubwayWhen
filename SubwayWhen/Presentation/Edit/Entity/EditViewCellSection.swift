//
//  EditViewCellSection.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/12/21.
//

import Foundation

import RxDataSources

struct EditViewCellSection: AnimatableSectionModelType {
    var sectionName : String
    var items: [Item]
}

extension EditViewCellSection{
    var identity: String {
        self.sectionName
    }
    
    typealias Item = SaveStation
    typealias Identity = String
    
    init(original: EditViewCellSection, items: [SaveStation]) {
        self = original
        self.items = items
    }
}
