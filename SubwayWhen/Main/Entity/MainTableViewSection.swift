//
//  MainTableViewSection.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/12/13.
//

import Foundation
import RxDataSources

struct MainTableViewSection{
    var section : String
    var items : [Item]
}

typealias Item =  MainTableViewCellData

extension MainTableViewSection : SectionModelType{
    init(original: MainTableViewSection, items: [MainTableViewCellData]) {
        self = original
        self.items = items
    }
}
