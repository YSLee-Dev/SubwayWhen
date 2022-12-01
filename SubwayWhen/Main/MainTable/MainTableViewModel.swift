//
//  MainTableViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/30.
//

import Foundation

import RxSwift
import RxCocoa

struct MainTableViewModel{
    // OUTPUT
    let cellData : Driver<[RealtimeStationArrival]>
    
    // INPUT
    let cellClick = PublishRelay<IndexPath>()
    let cellDelete = PublishRelay<RealtimeStationArrival>()
    
    let resultData = PublishRelay<[RealtimeStationArrival]>()
    let refreshOn = BehaviorRelay<Void>(value: Void())
    let editBtnClick = PublishRelay<Bool>()
    
    init(){
        self.cellData = self.resultData
            .asDriver(onErrorDriveWith: .empty())
    }
}
