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

@Reducer
class SearchFeature: NSObject {
    @Dependency(\.locationManager) private var locationManager
    @Dependency(\.totalLoad) private var totalLoad
    
    @ObservableState
    struct State: Equatable {
        var isFirst = true
        var locationAuth = false
        var nowLocation: LocationData?
        var nowVicinityStationList: [VicinityTransformData] = []
        var nowLiveDataLoading = [false, false]
        var nowTappedStationIndex: Int? = nil
        var nowUpLiveData: RealtimeStationArrival?
        var nowDownLiveData: RealtimeStationArrival?
        var recommendStationList: [String] = [
            // 통신 전 임시 값
            "강남", "교대", "선릉", "삼성", "을지로3가", "종각", "홍대입구", "잠실", "명동", "여의도", "가산디지털단지", "판교"
        ]
    }
    
    enum Action: Equatable {
        case onAppear
        case locationAuthResult(Bool)
        case locationDataRequest
        case locationDataResult(LocationData?)
        case locationToVicinityStationRequest
        case locationToVicinityStationResult([VicinityTransformData])
        case liveDataRequest
        case liveDataResult([RealtimeStationArrival])
        case stationTapped(Int?)
        case recommendStationRequest
        case recommendStationResult([String])
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                if state.isFirst {
                    state.isFirst = false
                    return .merge([
                        .send(.locationAuthResult(self.locationManager.locationAuthCheck())),
                        .send(.recommendStationRequest)
                    ])
                } else {
                    return .send(.locationAuthResult(self.locationManager.locationAuthCheck()))
                }
            case .locationAuthResult(let isOn):
                state.locationAuth = isOn
                if isOn && state.nowVicinityStationList.isEmpty {
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
                state.nowLocation = data
                return .send(.locationToVicinityStationRequest)
                
            case .locationToVicinityStationRequest:
                if state.nowLocation == nil {return .none}
                return .run { [location = state.nowLocation]send in
                    let data = await self.totalLoad.vicinityStationsDataLoad(x: location!.lat, y: location!.lon)
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
                
            case .stationTapped(let index):
                state.nowTappedStationIndex = index
                return .send(.liveDataRequest)
                
            case .recommendStationRequest:
                return .run { send in
                    let data = await self.totalLoad.defaultViewListLoad()
                    await send(.recommendStationResult(data))
                }
                
            case .recommendStationResult(let data):
                state.recommendStationList = data
                return .none
                
            default: return .none
            }
        }
    }
}
