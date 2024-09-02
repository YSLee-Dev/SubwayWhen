//
//  DetailFeature.swift
//  SubwayWhen
//
//  Created by 이윤수 on 8/26/24.
//

import Foundation

import ComposableArchitecture
import FirebaseAnalytics

@Reducer
struct DetailFeature: Reducer {
    weak var coordinatorDelegate: DetailVCDelegate?
    
    @Dependency (\.totalLoad) private var totalLoad
    @Dependency (\.dismiss) private var dismiss
    
    @ObservableState
    struct State: Equatable {
        let isDisposable: Bool
        var sendedLoadModel: DetailSendModel
        var nowArrivalData: [RealtimeStationArrival] = []
        var nowScheduleData: [ResultSchdule] = []
        var nowSculeduleSortedData: [ResultSchdule] = []
        var backStationName: String?
        var nextStationName: String?
        var nowArrivalLoading: Bool = false
        var nowTimer: Int?
        var nowScheduleLoading: Bool = false
        @Presents var dialogState: ConfirmationDialogState<Action.DialogAction>?
    }
    
    enum Action: Equatable {
        case viewInitialized
        case viewDisappear
        case backBtnTapped
        case exceptionLastStationBtnTapped
        case refreshBtnTapped
        case scheduleMoreBtnTapped
        case arrivalDataRequestSuccess([RealtimeStationArrival])
        case scheduleDataRequestSuccess([ResultSchdule])
        case scheduleDataSort
        case arrivalDataRequest
        case scheduleDataRequest
        case timerSettingRequest
        case timerDecrease
        case dialogAction(PresentationAction<DialogAction>)
        
        enum DialogAction: Equatable {
            case cancelBtnTapped
            case okBtnTapped
        }
    }
    
    enum TimerKey: Equatable {
        case refresh
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .viewInitialized:
                if state.nowScheduleData.isEmpty {
                    return .merge(
                        .send(.arrivalDataRequest),
                        .send(.scheduleDataRequest)
                    )
                } else {
                    return .send(.arrivalDataRequest)
                }
                
            case .arrivalDataRequest:
                state.nowArrivalLoading = true
                let sendedModel = state.sendedLoadModel
                let requestModel = DetailArrivalDataRequestModel(upDown: sendedModel.upDown, stationName: sendedModel.stationName, lineNumber: sendedModel.lineNumber, lineCode: sendedModel.lineCode, exceptionLastStation: sendedModel.exceptionLastStation)
                
                return .run { send in
                    let loadData = await self.totalLoad.singleLiveAsyncData(requestModel: requestModel)
                    try await Task.sleep(for: .milliseconds(350))
                    await send(.arrivalDataRequestSuccess(loadData))
                }
                
            case .scheduleDataRequest:
                let loadModel = state.sendedLoadModel
                let scheduleModel = ScheduleSearch(stationCode: loadModel.stationCode, upDown: loadModel.upDown, exceptionLastStation: loadModel.exceptionLastStation, line: loadModel.lineNumber, korailCode: loadModel.korailCode)
                state.nowScheduleLoading = true
                
                return  .run { send in
                    let loadData = await self.totalLoad.scheduleDataFetchAsyncData(searchModel: scheduleModel)
                    await send(.scheduleDataRequestSuccess(loadData))
                }
                
            case .arrivalDataRequestSuccess(let data):
                let backNextStationName = self.nextAndBackStationSearch(backId: data.first?.backStationId, nextId: data.first?.nextStationId, lineCode: state.sendedLoadModel.lineCode)
                state.nowArrivalData = data
                state.backStationName = backNextStationName[0]
                state.nextStationName = backNextStationName[1]
                state.nowArrivalLoading = false
                
                return .send(.timerSettingRequest)
                
            case .scheduleDataRequestSuccess(let data):
                state.nowScheduleData = data
                state.nowScheduleLoading = false
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
                
                if !((state.nowScheduleData.first?.type ?? .Unowned) == .Unowned) && state.nowScheduleData.count <= 1 { // 서울, 코레일 라인이면서, 정보없음 하나만 있는 경우 (정렬 데이터가 아닐때)
                    return .merge(
                        .send(.arrivalDataRequest),
                        .send(.scheduleDataRequest),
                        .cancel(id: TimerKey.refresh)
                    )
                } else {
                    return .merge(
                        .send(.arrivalDataRequest),
                        .send(.scheduleDataSort),
                        .cancel(id: TimerKey.refresh)
                    )
                }
                
            case .timerSettingRequest:
                if !FixInfo.saveSetting.detailAutoReload {return .none}
                state.nowTimer = 15
                
                return .run { send in
                    for _ in 1 ... 15 {
                        try await Task.sleep(for: .seconds(1))
                        await send(.timerDecrease)
                    }
                    await send(.refreshBtnTapped)
                }
                .cancellable(id: TimerKey.refresh)
                
            case .timerDecrease:
                if state.nowTimer == nil {return .none}
                state.nowTimer! -= 1
                return .none
                
            case .exceptionLastStationBtnTapped:
                if state.sendedLoadModel.exceptionLastStation.isEmpty {return .none}
                let msg = "\(state.sendedLoadModel.exceptionLastStation)행을 포함해서 재로딩 하시겠어요?\n재로딩은 일회성으로, 저장하지 않아요."
                state.dialogState = ConfirmationDialogState(title:  {
                    TextState("")
                }, actions: {
                    ButtonState(action: .okBtnTapped) {
                        TextState("재로딩")
                    }
                    ButtonState(role: .cancel, action: .cancelBtnTapped) {
                        TextState("취소")
                    }
                }, message: {
                    TextState(msg)
                })
                return .none
                
            case .dialogAction(.presented(.cancelBtnTapped)):
                state.dialogState = nil
                return .none
                
            case .dialogAction(.presented(.okBtnTapped)):
                state.dialogState = nil
                state.sendedLoadModel.exceptionLastStation = ""
                
                Analytics.logEvent("DetailVC_ExceptionBtnTap", parameters: [
                    "Exception" : "BTNTAP"
                ])
                
                return .merge(
                    .send(.arrivalDataRequest),
                    .send(.scheduleDataRequest)
                )
                
            case .backBtnTapped:
                self.coordinatorDelegate?.pop()
                return .none
                
            case .scheduleMoreBtnTapped:
                self.coordinatorDelegate?.scheduleTap(schduleResultData: (state.nowScheduleData, state.sendedLoadModel))
                return .none
                
            case .viewDisappear:
                self.coordinatorDelegate?.disappear()
                return .cancel(id: TimerKey.refresh)
                
            default: return .none
            }
        }
        .ifLet(\.dialogState, action: \.dialogAction)
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
    
    private func nextAndBackStationSearch(backId : String?, nextId : String?, lineCode: String) -> [String]{
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
        if lineCode == "1065" { // 공항철도는 반대
            return  [nextStation, backStation]
        } else {
            return  [backStation, nextStation]
        }
    }
}
