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
    var realtimeStationArrival: [TotalRealtimeStationArrival] = []
    var vicinityStationsData: [VicinityTransformData] = []
    var defaultViewListdata: [String] = []
    var searchStationName: [searchStationInfo] = []
    
    init() {}
    
    func scheduleDataFetchAsyncData(searchModel: ScheduleSearch, isDisposable: Bool) async -> [ResultSchdule]  {
        self.resultSchdule
    }
    
    func singleLiveAsyncData(requestModel: DetailArrivalDataRequestModel) async ->[TotalRealtimeStationArrival] {
        self.realtimeStationArrival.filter {$0.upDown == requestModel.upDown && requestModel.line.lineCode == $0.subWayId && !(requestModel.exceptionLastStation.contains($0.lastStation))}
    }
    
    func vicinityStationsDataLoad(x: Double, y: Double) async -> [VicinityTransformData] {
        self.vicinityStationsData
    }
    
    func defaultViewListLoad() async -> [String] {
        self.defaultViewListdata
    }
    
    func stationNameSearchReponse(_ stationName : String) async -> [searchStationInfo] {
        self.searchStationName
    }
}
