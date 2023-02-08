//
//  MainTableViewSection.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/12/13.
//

import Foundation
import RxDataSources

struct MainTableViewSection{
    var id : String
    var sectionName : String
    var items : [Item]
}

typealias Item =  MainTableViewCellData
typealias Identity = String

extension MainTableViewSection : AnimatableSectionModelType{
    init(original: MainTableViewSection, items: [MainTableViewCellData]) {
        self = original
        self.items = items
    }
    
    var identity : String{
        return self.id
    }
    
}
