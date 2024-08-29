//
//  TotalLoadTCADependencyProtocol.swift
//  SubwayWhenNetworking
//
//  Created by 이윤수 on 8/29/24.
//

import Foundation

protocol TotalLoadTCADependencyProtocol {
    func scheduleDataFetchAsyncData(searchModel: ScheduleSearch)  async -> [ResultSchdule]
    func singleLiveAsyncData(requestModel: DetailArrivalDataRequestModel)  async -> [RealtimeStationArrival]
}
