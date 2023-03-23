//
//  DetailResultScheduleModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/23.
//

import Foundation

class DetailResultScheduleModel : DetailResultScheduleModelProtocol{
    func resultScheduleToDetailResultSection(_ data : [ResultSchdule]) -> [DetailResultScheduleViewSectionData] {
        var sortArray : [DetailResultScheduleViewSectionData] = []
        for x in 0...24{
            let sortedData = data.filter{
                let index = $0.useArrTime.index($0.useArrTime.startIndex, offsetBy: 1)
                let count = 0...9 ~= x ? "0\(x)" : "\(x)"
                
                if $0.useArrTime != "0"{
                    return $0.useArrTime[$0.useArrTime.startIndex...index] == count
                }else{
                    return false
                }
                
            }
            
            let minute = sortedData.map{
                let startIndex = $0.useArrTime.index($0.useArrTime.startIndex, offsetBy: 3)
                let endIndex = $0.useArrTime.index(startIndex, offsetBy: 1)
                
                return String($0.useArrTime[startIndex...endIndex])
            }
            
            sortArray.append(.init(sectionName: "\(x)시", hour: x, items: [.init(id: "\(x)", hour: "\(x)", minute: minute, lastStation: sortedData.map{$0.lastStation}, startStation: sortedData.map{$0.startStation}, isFast: sortedData.map{$0.isFast})]))
        }
       return sortArray
    }
    
    func nowTimeMatcing(_ data: [DetailResultScheduleViewSectionData], nowHour : Int) -> Int{
        for x in data.enumerated(){
            if x.element.hour == nowHour{
                return x.offset
            }
        }
        return 0
    }
}
