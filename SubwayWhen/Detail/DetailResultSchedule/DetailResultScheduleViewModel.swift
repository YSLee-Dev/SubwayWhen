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
}
