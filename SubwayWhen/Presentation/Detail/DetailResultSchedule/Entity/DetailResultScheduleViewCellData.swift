//
//  DetailResultScheduleViewCellData.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/07.
//

import Foundation

import RxDataSources

struct DetailResultScheduleViewCellData : IdentifiableType, Equatable{
    let id : String
    let hour : String
    let minute : [String]
    let lastStation : [String]
    let startStation : [String]
    let isFast : [String]
}

extension DetailResultScheduleViewCellData{
    typealias Identity = String
    
    var identity: String{
        self.id
    }
}
