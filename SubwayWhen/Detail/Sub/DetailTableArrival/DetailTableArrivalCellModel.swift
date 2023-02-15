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
    let refreshBtnClick = PublishRelay<Void>()
    
    // OUTPUT
    let cellData : Driver<[RealtimeStationArrival]>
    let timer : Observable<Int>
    
    deinit{
        print("DetailTableArrivalCellModel DEINIT")
    }
    
    init(){
        self.cellData = self.realTimeData
            .asDriver(onErrorDriveWith: .empty())
        
        self.timer = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
    }
}
