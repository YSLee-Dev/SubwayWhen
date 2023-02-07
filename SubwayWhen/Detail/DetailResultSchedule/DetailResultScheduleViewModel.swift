//
//  DetailResultScheduleViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/25.
//

import Foundation

import RxSwift
import RxCocoa

struct DetailResultScheduleViewModel{
    // INPUT
    let scheduleData = BehaviorRelay<[ResultSchdule]>(value: [])
    let cellData = BehaviorRelay<MainTableViewCellData>(value: MainTableViewCellData(upDown: "", arrivalTime: "", previousStation: "", subPrevious: "", code: "", subWayId: "", stationName: "", lastStation: "", lineNumber: "", isFast: "", useLine: "", group: "", id: "", stationCode: "", exceptionLastStation: "", type: .real, backStationId: "", nextStationId: "", totalStationId: ""))
    
    // OUTPUT
    let resultDefaultData : Driver<MainTableViewCellData>
    let groupScheduleData : Driver<[DetailResultScheduleViewSectionData]>
    
    init(){
        self.resultDefaultData = self.cellData
            .asDriver(onErrorDriveWith: .empty())
        
        self.groupScheduleData = self.scheduleData
            .map{data -> [DetailResultScheduleViewSectionData] in
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
                    
                    sortArray.append(.init(sectionName: "\(x)시", items: [.init(id: "\(x)", hour: "\(x)", minute: minute, lastStation: sortedData.map{$0.lastStation})]))
                }
               return sortArray
            }
            .map{data in
                data.filter{
                    !($0.items.first!.minute.isEmpty)
                }
            }
            .asDriver(onErrorDriveWith: .empty())
    }
}
