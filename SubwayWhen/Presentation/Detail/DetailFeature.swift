//
//  DetailFeature.swift
//  SubwayWhen
//
//  Created by 이윤수 on 8/26/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct DetailFeature: Reducer {
    @Dependency (\.totalLoad) private var totalLoad
    @Dependency (\.dismiss) private var dismiss
    
    @ObservableState
    struct State: Equatable {
        let sendedLoadModel: DetailSendModel
        var nowArrivalData: [RealtimeStationArrival] = []
        var nowScheduleData: [ResultSchdule] = []
        var nowSculeduleSortedData: [ResultSchdule] = []
        var backStationName: String?
        var nextStationName: String?
        var nowArrivalLoading: Bool = false
        var nowTimer: Int?
    }
    
    enum Action: Equatable {
        case viewInitialized
        case backBtnTapped
        case exceptionLastStationBtnTapped
        case refreshBtnTapped
        case scheduleMoreBtnTapped
        case arrivalDataRequestSuccess([RealtimeStationArrival])
        case scheduleDataRequestSuccess([ResultSchdule])
        case scheduleDataSort
        case arrivalDataRequest
        case timerSettingRequest
        case timerDecrease
    }
    
    enum TimerKey: Equatable {
        case refresh
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .viewInitialized:
                let loadModel = state.sendedLoadModel
                let scheduleModel = ScheduleSearch(stationCode: loadModel.stationCode, upDown: loadModel.upDown, exceptionLastStation: loadModel.exceptionLastStation, line: loadModel.lineNumber, korailCode: loadModel.korailCode)
                
                return .merge(
                    .send(.arrivalDataRequest),
                    .run { send in
                        let loadData = await self.totalLoad.scheduleDataFetchAsyncData(type: ScheduleType.lineNumberScheduleType(line: loadModel.lineNumber), searchModel: scheduleModel)
                        await send(.scheduleDataRequestSuccess(loadData))
                    }
                )
                
            case .arrivalDataRequest:
                state.nowArrivalLoading = true
                let stationName = state.sendedLoadModel.stationName
                
                return .run { send in
                    let loadData = await self.totalLoad.singleLiveAsyncData(station: stationName)
                    try await Task.sleep(for: .milliseconds(350))
                    await send(.arrivalDataRequestSuccess(loadData.realtimeArrivalList))
                }
                
            case .arrivalDataRequestSuccess(let data):
                let backNextStationName = self.nextAndBackStationSearch(backId: data.first?.backStationId, nextId: data.first?.nextStationId)
                
                state.nowArrivalData = data
                state.backStationName = backNextStationName[0]
                state.nextStationName = backNextStationName[1]
                state.nowArrivalLoading = false
                
                return .send(.timerSettingRequest)
                
            case .scheduleDataRequestSuccess(let data):
                state.nowScheduleData = data
                return .send(.scheduleDataSort)
                
            case .scheduleDataSort:
                if FixInfo.saveSetting.detailScheduleAutoTime {
                    state.nowSculeduleSortedData = self.scheduleSort(state.nowScheduleData)
                } else {
                    state.nowSculeduleSortedData = state.nowScheduleData
                }
                return .none
                
            case .refreshBtnTapped:
                if state.nowArrivalLoading {return .none}
                state.nowTimer = nil
                return .merge(
                    .send(.arrivalDataRequest),
                    .cancel(id: TimerKey.refresh)
                )
                
            case .timerSettingRequest:
                if !FixInfo.saveSetting.detailAutoReload {return .none}
                state.nowTimer = 15
                
                return .run { send in
                    for _ in 1 ... 15 {
                        try await Task.sleep(for: .seconds(1))
                        await send(.timerDecrease)
                    }
                    await send(.arrivalDataRequest)
                }
                .cancellable(id: TimerKey.refresh)
                
            case .timerDecrease:
                if state.nowTimer == nil {return .none}
                state.nowTimer! -= 1
                return .none
                
            default: return .none
            }
        }
    }
    
    private func scheduleSort(_ scheduleList : [ResultSchdule]) -> [ResultSchdule] {
        let formatter = DateFormatter()
        formatter.dateFormat = "HHmmss"
        
        guard let now = Int(formatter.string(from: Date())) else {return scheduleList}
        let schedule = scheduleList.filter{
            guard let scheduleTime = Int($0.startTime.components(separatedBy: ":").joined()) else {return false}
            if scheduleTime >= now{
                return true
            } else {
                return false
            }
        }
        
        if schedule.isEmpty {
            return scheduleList
        } else if schedule.count == 1 {
            guard let first = schedule.first else {return []}
            return [first]
        } else {
            return schedule
        }
    }
    
    private func nextAndBackStationSearch(backId : String?, nextId : String?) -> [String]{
        var backStation : String = ""
        var nextStation : String = ""
        
        guard let fileUrl = Bundle.main.url(forResource: "DetailStationIdList", withExtension: "plist") else {return  [backStation, nextStation]}
        guard let data = try? Data(contentsOf: fileUrl) else {return  [backStation, nextStation]}
        guard let decodingData = try? PropertyListDecoder().decode([DetailStationId].self, from: data) else {return  [backStation, nextStation]}
        
        for x in decodingData{
            if x.stationId == backId{
                backStation = x.stationName
            }
            
            if x.stationId == nextId{
                nextStation = x.stationName
            }
            
            if backStation != "" && nextStation != ""{
                break
            }
        }
        return  [backStation, nextStation]
    }
    
    private func arrivalDataMatching(station : DetailLoadData, arrivalData : [RealtimeStationArrival]) -> [RealtimeStationArrival]{
        var list = [RealtimeStationArrival(upDown: station.upDown, arrivalTime: "", previousStation: "현재 실시간 열차 데이터가 없어요.", subPrevious: "", code: "", subWayId: "", stationName: station.stationName, lastStation: "\(station.exceptionLastStation)행 제외", lineNumber: station.lineNumber, isFast: nil, backStationId: station.backStationId, nextStationId: station.nextStationId, trainCode: "")]
        
        for x in arrivalData {
            if station.upDown == x.upDown && station.lineCode == x.subWayId && !(station.exceptionLastStation.contains(x.lastStation)){
                if list.count == 1{
                    list.insert(x, at: 0)
                }else if list.count == 2{
                    list.insert(x, at: 1)
                    list.removeLast()
                    return list
                }
            }
        }
        return list
    }
}
