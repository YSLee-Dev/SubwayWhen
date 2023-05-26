//
//  DetailResultScheduleViewModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/28.
//

import Foundation

import RxSwift
import RxCocoa

protocol DetailResultScheduleViewModelProtocol{
    var scheduleData : BehaviorRelay<[ResultSchdule]>{get}
    var cellData : BehaviorRelay<DetailLoadData>{get}
    var scheduleVCExceptionStationRemove : PublishRelay<Void>{get}
    
    var resultDefaultData : Driver<DetailLoadData>{get}
    var groupScheduleData : Driver<[DetailResultScheduleViewSectionData]>{get}
    var nowHourSectionSelect : Driver<Int>{get}
    var scheduleVCExceptionLastStationBtnClick : Driver<Void>{get}
    
    var detailResultScheduleTopViewModel : DetailResultScheduleTopViewProtocol{get}
}
