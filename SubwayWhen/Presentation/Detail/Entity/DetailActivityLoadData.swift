//
//  DetailActivityLoadData.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/05/09.
//

import Foundation

struct DetailActivityLoadData{
    let saveStation : String
    let saveLine : String
    let nowStation : String
    let status : String
    let statusMSG : String
    let lastUpdate : String
    
    var useNowStation : String {
        return self.nowStation == self.saveStation ? "" : self.nowStation
    }
}
