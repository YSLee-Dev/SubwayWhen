//
//  DetailModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/04.
//

import Foundation

import RxSwift

struct DetailModel{
    // DATA
    let stationIdList = DetailStationIdList()
    
    func nextAndBackStationSearch(backId : String, nextId : String) -> [String]{
        var backStation : String = ""
        var nextStation : String = ""
        
        for x in stationIdList.list{
            if x.stationId == backId{
                backStation = x.stationName
            }
            
            if x.stationId == nextId{
                nextStation = x.stationName
            }
            
            if backStation != "" && nextStation != ""{
                break
            }
            
        }
        return [backStation, nextStation]
    }
}
