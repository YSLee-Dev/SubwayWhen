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
        let sendedStationName: String
        let sendedScheduleModel: ScheduleSearch
        var nowArrivalData: [RealtimeStationArrival]?
        var nowScheduleData: [ResultSchdule]?
        var nowSculeduleSortedData: [ResultSchdule]?
        var backStationName: String?
        var nextStationName: String?
        var nowArrivalLoading: Bool = false
    }
    
    enum Action: Equatable {
        case viewInitialized
        case backBtnTapped
        case exceptionLastStationBtnTapped
        case refreshBtnTapped
        case scheduleMoreBtnTapped
        case arrivalDataRequestSuccess([RealtimeStationArrival])
        case scheduleDataRequestSuccess([ResultSchdule])
        case arrivalDataRequest(String)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .viewInitialized:
                let stationName = state.sendedStationName
                let scheduleModel = state.sendedScheduleModel
                
                return .merge(
                    .send(.arrivalDataRequest(stationName)),
                    .run { send in
                        let loadData = await self.totalLoad.scheduleDataFetchAsyncData(type: scheduleModel.lineScheduleType, searchModel: scheduleModel)
                        await send(.scheduleDataRequestSuccess(loadData))
                    }
                )
                
            case .arrivalDataRequest(let stationName):
                state.nowArrivalLoading = true
                
                return .run { send in
                    let loadData = await self.totalLoad.singleLiveAsyncData(station: stationName)
                    await send(.arrivalDataRequestSuccess(loadData.realtimeArrivalList))
                }
                
            case .arrivalDataRequestSuccess(let data):
                let backNextStationName = self.nextAndBackStationSearch(backId: data.first?.backStationId, nextId: data.first?.nextStationId)
                
                state.nowArrivalData = data
                state.backStationName = backNextStationName[0]
                state.nextStationName = backNextStationName[1]
                state.nowArrivalLoading = false
                
                return .none
                
            case .scheduleDataRequestSuccess(let data):
                state.nowScheduleData = data
                
                if FixInfo.saveSetting.detailScheduleAutoTime {
                    state.nowScheduleData = self.scheduleSort(data)
                } else {
                    state.nowScheduleData = data
                }
                return .none
                
            case .refreshBtnTapped:
                return .send(.arrivalDataRequest(state.sendedStationName))
                
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
}
