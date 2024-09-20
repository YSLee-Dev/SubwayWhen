//
//  TestTotalLoadTCADepdency.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 9/20/24.
//

import Foundation
import ComposableArchitecture

class TestTotalLoadTCADependency: TotalLoadTCADependencyProtocol {
    var resultSchdule: [ResultSchdule] = []
    var realtimeStationArrival: [RealtimeStationArrival] = []
    
    init() {}
    
    func scheduleDataFetchAsyncData(searchModel: ScheduleSearch) async -> [ResultSchdule] {
        return self.resultSchdule
    }
    
    func singleLiveAsyncData(requestModel: DetailArrivalDataRequestModel) async -> [RealtimeStationArrival] {
        return self.realtimeStationArrival
    }
}
