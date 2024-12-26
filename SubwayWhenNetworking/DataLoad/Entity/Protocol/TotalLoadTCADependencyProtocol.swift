//
//  TotalLoadTCADependencyProtocol.swift
//  SubwayWhenNetworking
//
//  Created by 이윤수 on 8/29/24.
//

import Foundation

protocol TotalLoadTCADependencyProtocol {
    func scheduleDataFetchAsyncData(searchModel: ScheduleSearch, isDisposable: Bool)  async -> [ResultSchdule]  
    func singleLiveAsyncData(requestModel: DetailArrivalDataRequestModel) async ->[TotalRealtimeStationArrival]
    func vicinityStationsDataLoad(x: Double, y: Double) async -> [VicinityTransformData]
    func defaultViewListLoad() async -> [String]
    func stationNameSearchReponse(_ stationName : String) async -> [searchStationInfo]
}
