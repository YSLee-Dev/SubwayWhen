//
//  DetailTableArrivalCellModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/05.
//

import Foundation

import RxSwift
import RxCocoa

class DetailTableArrivalCellModel {
    // INPUT
    let realTimeData = BehaviorRelay<[RealtimeStationArrival]>(value: [])
    
    // OUTPUT
    let cellData : Driver<[RealtimeStationArrival]>
    
    init(){
        self.cellData = self.realTimeData
            .asDriver(onErrorDriveWith: .empty())
    }
}
