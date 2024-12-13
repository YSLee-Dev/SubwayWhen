//
//  SearchFeature.swift
//  SubwayWhen
//
//  Created by 이윤수 on 12/4/24.
//

import Foundation

import ComposableArchitecture
import FirebaseAnalytics
import CoreLocation
import Combine

struct SearchFeatureStationTapSendModel: Equatable {
    let index: Int
    let type: StationTapSendModelType
    
    enum StationTapSendModelType {
        case recommend, location
    }
}

@Reducer
class SearchFeature: NSObject {
    @Dependency(\.locationManager) private var locationManager
    @Dependency(\.totalLoad) private var totalLoad
    
    @ObservableState
    struct State: Equatable {
        var nowVicinityStationList: [VicinityTransformData] = []
        var nowLiveDataLoading = [false, false]
        var nowTappedStationIndex: Int? = nil
        var nowUpLiveData: TotalRealtimeStationArrival?
        var nowDownLiveData: TotalRealtimeStationArrival?
        var nowStationSearchList: [searchStationInfo] = []
        var nowSearchLoading = false
        var nowRecommendStationList: [String] = [
            // 통신 전 임시 값
            "강남", "교대", "선릉", "삼성", "을지로3가", "종각", "홍대입구", "잠실", "명동", "여의도", "가산디지털단지", "판교"
        ]
        var isSearchMode = false
        var isFirst = true
        var searchQuery = ""
        var locationAuth = false
        var isDisposableSearchUpdown: Bool?
        
        @Presents var dialogState: ConfirmationDialogState<Action.DialogAction>?
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case locationAuthRequest
        case locationAuthResult([Bool]) // index0 : 자동 여부 (버튼클릭 -> 수동), index1: result
        case locationDataRequest
        case locationDataResult(LocationData?)
        case locationToVicinityStationRequest(LocationData)
        case locationToVicinityStationResult([VicinityTransformData])
        case locationStationTapped(Int?)
        case liveDataRequest
        case liveDataResult([TotalRealtimeStationArrival])
        case recommendStationRequest
        case recommendStationResult([String])
        case refreshBtnTapped
        case vicinityListOpenBtnTapped
        case disposableDetailBtnTapped
        case dialogAction(PresentationAction<DialogAction>)
        case isSearchMode(Bool)
        case stationSearchRequest
        case stationSearchResult([searchStationInfo])
        case searchResultTapped(Int)
        case stationTapped(SearchFeatureStationTapSendModel)
        case disposableDetailPushRequest
        
        enum DialogAction: Equatable {
            case cancelBtnTapped
            case upDownBtnTapped(Bool) // 상행/외선이 true, 하행/내선이 false
        }
    }
    
    enum Key: Equatable, CaseIterable {
        case liveDataRequest
        case searchDelay
    }
    
    weak var delegate: SearchVCActionProtocol?
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                if state.isFirst {
                    state.isFirst = false
                    return .merge([
                        .send(.locationAuthResult([true, self.locationManager.locationAuthCheck()])),
                        .send(.recommendStationRequest)
                    ])
                } else {
                    return .send(.locationAuthResult([true, self.locationManager.locationAuthCheck()]))
                }
                
            case .locationAuthRequest:
                return .run { send in
                    let isOn = await self.locationManager.locationAuthRequest()
                    await send(.locationAuthResult([false, isOn]))
                }
                
            case .locationAuthResult(let isOn):
                state.locationAuth = isOn[1]
                if !isOn[0] && !isOn[1]  {
                    return .send(.vicinityListOpenBtnTapped) // 해당 모달 내부에서 안내멘트를 전달해요.
                } else if isOn[1] && state.nowVicinityStationList.isEmpty {
                    return .send(.locationDataRequest)
                } else {
                    return .none
                }
                
            case .locationDataRequest:
                return .run { send in
                    let data = await self.locationManager.locationRequest()
                    await send(.locationDataResult(data))
                }
                
            case .locationDataResult(let data):
                guard let location = data else {return .none}
                return .send(.locationToVicinityStationRequest(location))
                
            case .locationToVicinityStationRequest(let location):
                return .run { send in
                    let data = await self.totalLoad.vicinityStationsDataLoad(x: location.lon, y: location.lat)
                    return await send(.locationToVicinityStationResult(data))
                }
                
            case .locationToVicinityStationResult(let data):
                state.nowVicinityStationList = data
                return .none
                
            case .liveDataRequest:
                if state.nowTappedStationIndex == nil {return .none}
                let tappedData = state.nowVicinityStationList[state.nowTappedStationIndex!]
                guard let line = SubwayLineData(rawValue: tappedData.lineColorName) else {return .none}
                state.nowLiveDataLoading = [true, true]
                return .merge([
                    .run { send in
                        let data = await self.totalLoad.singleLiveAsyncData(requestModel: .init(upDown: tappedData.line == "2호선" ? "외선" : "상행", stationName: tappedData.name, line: line, exceptionLastStation: ""))
                        await send(.liveDataResult(data))
                    },
                    .run { send in
                        let data = await self.totalLoad.singleLiveAsyncData(requestModel: .init(upDown: tappedData.line == "2호선" ? "내선" : "하행", stationName: tappedData.name, line: line, exceptionLastStation: ""))
                        await send(.liveDataResult(data))
                    }
                ])
                .cancellable(id: Key.liveDataRequest)
                
            case .liveDataResult(let data):
                if data.first == nil {return .none}
                if data.first!.upDown == "상행" || data.first!.upDown == "외선" {
                    state.nowUpLiveData = data.first!
                    state.nowLiveDataLoading[0] = false
                } else {
                    state.nowDownLiveData = data.first!
                    state.nowLiveDataLoading[1] = false
                }
                return .none
                
            case .locationStationTapped(let index):
                state.nowTappedStationIndex = index
                return .concatenate([
                    .cancel(id: Key.liveDataRequest),
                    .send(.liveDataRequest)
                ])
                
            case .recommendStationRequest:
                return .run { send in
                    let data = await self.totalLoad.defaultViewListLoad()
                    await send(.recommendStationResult(data))
                }
                
            case .recommendStationResult(let data):
                state.nowRecommendStationList = data
                return .none
                
            case .refreshBtnTapped:
                return .send(.liveDataRequest)
                
            case .vicinityListOpenBtnTapped:
                self.delegate?.locationPresent(data: state.nowVicinityStationList)
                return .none
                
            case .disposableDetailBtnTapped:
                let upDown = state.nowUpLiveData?.upDown ?? "" == "상행" ? "상/하행" : "외/내선"
                state.dialogState = .init(title: {
                    TextState("")
                }, actions: {
                    ButtonState(action: .upDownBtnTapped(true)) {
                        TextState(state.nowUpLiveData?.upDown ?? "")
                    }
                    ButtonState(action: .upDownBtnTapped(false)) {
                        TextState(state.nowDownLiveData?.upDown ?? "")
                    }
                    ButtonState(role: .cancel, action: .cancelBtnTapped) {
                        TextState("취소")
                    }
                }, message: {
                    TextState("\(upDown) 정보를 확인해주세요.")
                })
                return .none
                
            case .dialogAction(let action):
                switch action {
                case .presented(.upDownBtnTapped(let isUp)):
                    guard let index = state.nowTappedStationIndex else {return .none}
                    state.searchQuery = state.nowVicinityStationList[index].name
                    state.isDisposableSearchUpdown = isUp
                    state.isSearchMode = true
                    state.nowSearchLoading = true
                    return .send(.stationSearchRequest)
                    
                default: break
                }
                state.dialogState = nil
                return .none
                
            case .isSearchMode(let isOn):
                state.isSearchMode = isOn
                if !isOn {
                    state.searchQuery = ""
                }
                return .none
                
            case .binding(\.searchQuery):
                if state.searchQuery.isEmpty {
                    state.nowStationSearchList = []
                    state.nowSearchLoading = false
                    return .cancel(id: Key.searchDelay)
                } else if state.nowStationSearchList.firstIndex(where: {$0.stationName == state.searchQuery}) != nil {
                    return .none
                }
                
                state.nowSearchLoading = true
                return .concatenate([
                    .cancel(id: Key.searchDelay),
                    .run { send in
                        try await Task.sleep(for: .milliseconds(500))
                        await send(.stationSearchRequest)
                    }
                ])
                .cancellable(id: Key.searchDelay)
                
            case .stationSearchRequest:
                return .run { [name = state.searchQuery] send in
                    let result = await self.totalLoad.stationNameSearchReponse(name)
                    try await Task.sleep(for: .milliseconds(500))
                    await send(.stationSearchResult(result))
                }
                
            case .stationSearchResult(let result):
                state.nowStationSearchList = result
                state.nowSearchLoading = false
                if state.isDisposableSearchUpdown != nil {
                    return .send(.disposableDetailPushRequest)
                } else {
                    return .none
                }
               
            case .searchResultTapped(let index):
                self.delegate?.modalPresent(data: state.nowStationSearchList[index])
                return .none
                
            case .stationTapped(let model):
                state.nowSearchLoading = true
                state.isSearchMode = true
                state.searchQuery = model.type == .recommend ?  state.nowRecommendStationList[model.index] : state.nowVicinityStationList[model.index].name
                return .send(.stationSearchRequest)
                
            case .disposableDetailPushRequest:
                guard let isUp = state.isDisposableSearchUpdown,
                      let data = isUp ? state.nowUpLiveData : state.nowDownLiveData,
                      let searchIndex = state.nowStationSearchList.firstIndex(where: {$0.lineCode == data.subWayId})
                else {
                    state.isDisposableSearchUpdown = nil
                    return .none
                }
                let searchData = state.nowStationSearchList[searchIndex]
                state.isDisposableSearchUpdown = nil
                self.delegate?.disposableDetailPush(data: .init(upDown: data.upDown, stationName: data.stationName, lineNumber: searchData.lineNumber.rawValue, stationCode: searchData.stationCode, lineCode: searchData.lineCode, exceptionLastStation: "", korailCode: ""))
                return .none
                
            default: return .none
            }
        }
    }
}
