//
//  ReportContentsModalCellData.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/07.
//

import Foundation

import RxDataSources

struct ReportContentsModalCellData : Equatable, IdentifiableType{
    let title : String
    let iconName : String
    let contents : String
}

extension ReportContentsModalCellData{
    var identity: String{
        self.title + iconName
    }
}
