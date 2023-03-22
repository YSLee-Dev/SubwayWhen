//
//  DetailTableArrivalCellModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/05.
//

import Foundation

import RxSwift
import RxCocoa

class DetailTableArrivalCellModel : DetailTableArrivalCellModelProtocol {
    // INPUT
    let realTimeData = BehaviorRelay<[RealtimeStationArrival]>(value: [])
    let refreshBtnClick = PublishRelay<Void>()
    let superTimer = PublishSubject<Int>()
    
    // OUTPUT
    let cellData : Driver<[RealtimeStationArrival]>
    let timer : Driver<Int>
    
    deinit{
        print("DetailTableArrivalCellModel DEINIT")
    }
    
    init(){
        self.cellData = self.realTimeData
            .asDriver(onErrorDriveWith: .empty())
        
        self.timer = self.superTimer
            .asDriver(onErrorDriveWith: .empty())
        
    }
}
