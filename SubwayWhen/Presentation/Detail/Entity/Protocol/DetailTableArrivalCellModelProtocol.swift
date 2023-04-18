//
//  DetailTableArrivalCellModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/22.
//

import Foundation

import RxSwift
import RxCocoa

protocol DetailTableArrivalCellModelProtocol{
    // INPUT
    var realTimeData : BehaviorRelay<[RealtimeStationArrival]>{get}
    var refreshBtnClick : PublishRelay<Void>{get}
    var superTimer : PublishSubject<Int>{get}
    
    // OUTPUT
    var cellData : Driver<[RealtimeStationArrival]>{get}
    var timer : Driver<Int>{get}
    
    var arrivalLiveViewModel : DetailTableArrivalLiveViewModelProtocol {get}
}
