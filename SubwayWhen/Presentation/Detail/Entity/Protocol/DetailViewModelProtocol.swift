//
//  DetailViewModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/28.
//

import Foundation

import RxSwift
import RxCocoa

protocol DetailViewModelProtocol {
    var detailModel : DetailModelProtocol{get}
    var headerViewModel : DetailTableHeaderViewModelProtocol{get}
    var arrivalCellModel : DetailTableArrivalCellModelProtocol{get}
    var scheduleCellModel : DetailTableScheduleCellModelProtocol{get}
    
    var detailViewData : BehaviorRelay<DetailLoadData>{get}
    var exceptionLastStationRemoveReload : PublishRelay<Void>{get}
    
    var cellData : Driver<[DetailTableViewSectionData]>{get}
    var moreBtnClickData : Driver<schduleResultData>{get}
    var exceptionLastStationRemoveBtnClick : Driver<DetailLoadData>{get}
    
    var nowData : BehaviorRelay<[DetailTableViewSectionData]>{get}
    var scheduleData : PublishRelay<[ResultSchdule]>{get}
    var arrivalData : PublishRelay<[RealtimeStationArrival]>{get}
}
