//
//  TotalLoadTCADependency.swift
//  SubwayWhenNetworking
//
//  Created by 이윤수 on 8/29/24.
//

import Foundation
import RxSwift

class TotalLoadTCADependency: TotalLoadTCADependencyProtocol {
    private var totalModel : TotalLoadProtocol
    private let bag = DisposeBag()
    
    init(totalModel : TotalLoadProtocol = TotalLoadModel()){
        self.totalModel = totalModel
    }
    
    func scheduleDataFetchAsyncData(searchModel: ScheduleSearch)  async -> [ResultSchdule]  {
        var scheduleResult: Observable<[ResultSchdule]>!
        if searchModel.lineScheduleType  == .Korail{
            scheduleResult = self.totalModel.korailSchduleLoad(scheduleSearch: searchModel, isFirst: false, isNow: false, isWidget: false)
        } else if searchModel.lineScheduleType == .Seoul {
            scheduleResult = self.totalModel.seoulScheduleLoad(searchModel, isFirst: false, isNow: false, isWidget: false)
        } else {
            return [.init(startTime: "정보없음", type: .Unowned, isFast: "", startStation: "", lastStation: "")]
        }
        
        return await withCheckedContinuation { continuation  in
            scheduleResult
                .subscribe(onNext: { data in
                    continuation.resume(returning: data)
                })
                .disposed(by: self.bag)
        }
    }
    
    func singleLiveAsyncData(requestModel: DetailArrivalDataRequestModel)  async -> [RealtimeStationArrival] {
        await withCheckedContinuation { continuation  in
            self.totalModel.singleLiveDataLoad(requestModel: requestModel)
                .subscribe(onNext: { data in
                    continuation.resume(returning: data)
                })
                .disposed(by: self.bag)
        }
    }
}
