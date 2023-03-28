//
//  ResultVCSection.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/12/14.
//

import Foundation

import RxDataSources


struct ResultVCSection : Equatable{
    var section : String
    var items : [resultCellData]
}

typealias resultCellData = ResultVCCellData

extension ResultVCSection : AnimatableSectionModelType{
    init(original: ResultVCSection, items: [ResultVCCellData]) {
        self = original
        self.items = items
    }
    
    typealias Identity = String
    
    var identity: String {
        self.section
    }
    
}
