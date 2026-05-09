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
        case recommend, location, searchQueryRecommend
    }
}

enum AutoDelegateAction: Equatable {
    case disposableDetail(Bool)
    case plusModal
}

@Reducer
struct SearchFeature: Reducer {
    @Dependency(\.locationManager) private var locationManager
    @Dependency(\.totalLoad) private var totalLoad
    
    @ObservableState
    struct State: Equatable {
        var nowVicinityStationList: [VicinityTransformData] = []
        var nowVicintyStationLoading = false
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
        fileprivate var nowSearchQueryRecommendList: [SearchQueryRecommendData] = [] // 파이어베이스에서 통신 받은 값
        var filteredSearchQueryRecommendList: [SearchQueryRecommendData] = [] // 위 값을 현재 쿼리를 통해 필터링 거친 값
        var isSearchMode = false
        fileprivate var isFirst = true
        var searchQuery = ""
        var locationAuth = false
        fileprivate var isAutoDelegateAction: AutoDelegateAction?
        fileprivate var lastVicintySearchTime: Date?
        
        @Presents var dialogState: ConfirmationDialogState<Action.DialogAction>?
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case locationAuthRequest
        case locationAuthResult([Bool]) // index0 : 자동 여부 (버튼클릭 -> 수동), index1: result
        case locationDataRequest
        case locationDataResult(LocationData?)
        case locationToVicinityRefreshBtnTapped
        case locationToVicinityStationRequest(LocationData)
        case locationToVicinityStationResult([VicinityTransformData])
        case locationStationTapped(Int?)
        case liveDataRequest
        case liveDataResult([TotalRealtimeStationArrival])
        case recommendStationRequest
        case recommendStationResult([String])
        case searchQueryRecommendListRequest
        case searchQueryRecommendListResult([SearchQueryRecommendData])
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
        case stationAddBtnTapped
        case reportBtnTapped
        
        enum DialogAction: Equatable {
            case cancelBtnTapped
            case upDownBtnTapped(Bool) // 상행/내선 true, 하행/외선이 false
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
                        .send(.recommendStationRequest),
                        .send(.searchQueryRecommendListRequest)
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
                } else if isOn[1] && state.nowTappedStationIndex != nil { // 선택된 지하철역이 있는 상태에서 재진입 했을 때
                    return .send(.refreshBtnTapped)
                } else {
                    return .none
                }
                
            case .locationToVicinityRefreshBtnTapped:
                if let lastTime = state.lastVicintySearchTime,
                   lastTime.addingTimeInterval(300) > Date.now {
                    state.dialogState = .init(title: {
                        TextState("")
                    }, actions: {
                        ButtonState(action: .cancelBtnTapped) {
                            TextState("확인")
                        }
                    }, message: {
                        TextState(
                            "가까운 지하철역 찾기 기능은 5분에 한번씩 조회할 수 있어요.\n\(Int(abs(Date.now.timeIntervalSince(lastTime.addingTimeInterval(300)))))초 후에 다시 시도해주세요."
                        )
                    })
                    return .none
                }
                state.nowTappedStationIndex = nil
                state.nowVicinityStationList = []
                return .send(.locationAuthResult([true, self.locationManager.locationAuthCheck()]))
                
            case .locationDataRequest:
                state.nowVicintyStationLoading = true
                return .run { send in
                    let data = await self.locationManager.locationRequest()
                    await send(.locationDataResult(data))
                }
                
            case .locationDataResult(let data):
                guard let location = data else {
                    state.nowVicintyStationLoading = false
                    return .none
                }
                return .send(.locationToVicinityStationRequest(location))
                
            case .locationToVicinityStationRequest(let location):
                return .run { send in
                    try? await Task.sleep(for: .milliseconds(200))
                    let data = await self.totalLoad.vicinityStationsDataLoad(x: location.lon, y: location.lat)
                    return await send(.locationToVicinityStationResult(data))
                }
                
            case .locationToVicinityStationResult(let data):
                state.nowVicintyStationLoading = false
                state.nowVicinityStationList = data
                state.lastVicintySearchTime = .now
                return .none
                
            case .liveDataRequest:
                guard let index = state.nowTappedStationIndex else { return .none }
                let tappedData = state.nowVicinityStationList[index]
                guard let line = SubwayLineData(rawValue: tappedData.lineColorName) else {return .none}
                state.nowLiveDataLoading = [true, true]
                return .merge([
                    .run { send in
                        let data = await self.totalLoad.singleLiveAsyncData(requestModel: .init(upDown: tappedData.line.upDownText(isUp: true), stationName: tappedData.name, line: line, exceptionLastStation: ""))
                        await send(.liveDataResult(data))
                    },
                    .run { send in
                        let data = await self.totalLoad.singleLiveAsyncData(requestModel: .init(upDown: tappedData.line.upDownText(isUp: false), stationName: tappedData.name, line: line, exceptionLastStation: ""))
                        await send(.liveDataResult(data))
                    }
                ])
                .cancellable(id: Key.liveDataRequest)
                
            case .liveDataResult(let data):
                guard let firstData = data.first, let index = state.nowTappedStationIndex else { return .none }
                let tappedData = state.nowVicinityStationList[index]
                guard let line = SubwayLineData(rawValue: tappedData.lineColorName) else { return .none }

                // 9호선은 상하행이 반대이기 때문에 아래와 같이 개발
                if (line != .nine && firstData.upDown == "상행") || (line == .nine && firstData.upDown == "하행") || firstData.upDown == "내선" {
                    state.nowUpLiveData = firstData
                    state.nowLiveDataLoading[0] = false
                } else {
                    state.nowDownLiveData = firstData
                    state.nowLiveDataLoading[1] = false
                }
                return .none
                
            case .locationStationTapped(let index):
                guard let index = index else {
                    // 선택을 취소한 경우
                    state.nowTappedStationIndex = index
                    return .none
                }
                let tappedData = state.nowVicinityStationList[index]
                guard let line = SubwayLineData(rawValue: tappedData.lineColorName) else {return .none}
                // 지원되지 않는 노선을 선택한 경우
                if line.lineCode == "" {
                    state.dialogState = self.errorPopup(msg: "해당 노선은 서비스를 지원하지 않아요.\n더 많은 노선을 지원하기 위해 노력하겠습니다.")
                    return .none
                } else {
                    state.nowTappedStationIndex = index
                    return .concatenate([
                        .cancel(id: Key.liveDataRequest),
                        .send(.liveDataRequest)
                    ])
                }
                
            case .recommendStationRequest:
                return .run { send in
                    let data = await self.totalLoad.defaultViewListLoad()
                    await send(.recommendStationResult(data))
                }
                
            case .recommendStationResult(let data):
                state.nowRecommendStationList = data
                return .none
                
            case .searchQueryRecommendListRequest:
                return .run { send in
                    let data = await self.totalLoad.searchQueryRecommendListLoad()
                    await send(.searchQueryRecommendListResult(data))
                }
                
            case .searchQueryRecommendListResult(let data):
                state.nowSearchQueryRecommendList = data
                return .none
                
            case .refreshBtnTapped:
                return .send(.liveDataRequest)
                
            case .vicinityListOpenBtnTapped:
                self.delegate?.locationPresent(data: state.nowVicinityStationList)
                return .none
                
            case .disposableDetailBtnTapped:
                guard let line = getTappedLineOrShowError(&state) else {
                    return .none
                }
                
                state.dialogState = .init(title: {
                    TextState("")
                }, actions: {
                    ButtonState(action: .upDownBtnTapped(line != .nine)) {
                        TextState(line.rawValue.upDownText(isUp: true))
                    }
                    ButtonState(action: .upDownBtnTapped(line == .nine)) {
                        TextState(line.rawValue.upDownText(isUp: false))
                    }
                    ButtonState(role: .cancel, action: .cancelBtnTapped) {
                        TextState("취소")
                    }
                }, message: {
                    TextState("\(line.rawValue.upDownText(isUp: true))/\(line.rawValue.upDownText(isUp: false)) 정보를 확인해주세요.")
                })
                return .none
                
            case .dialogAction(let action):
                switch action {
                case .presented(.upDownBtnTapped(let isUp)):
                    guard let index = state.nowTappedStationIndex else {return .none}
                    state.searchQuery = state.nowVicinityStationList[index].name
                    state.isAutoDelegateAction = .disposableDetail(isUp)
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
                    state.nowStationSearchList = []
                    state.filteredSearchQueryRecommendList = []
                }
                return .none
                
            case .binding(\.searchQuery):
                if state.searchQuery.isEmpty {
                    state.nowStationSearchList = []
                    state.filteredSearchQueryRecommendList = []
                    state.nowSearchLoading = false
                    return .none
                } else if state.nowStationSearchList.firstIndex(where: {$0.stationName == state.searchQuery}) != nil {
                    return .none
                }
                
                if !state.nowSearchLoading {
                    state.nowSearchLoading = true
                    state.filteredSearchQueryRecommendList = []
                }
                
                return .send(.stationSearchRequest)
                    .debounce(id: Key.searchDelay, for: 0.7, scheduler: DispatchQueue.main)
                
            case .stationSearchRequest:
                if state.searchQuery.isEmpty {
                    state.nowStationSearchList = []
                    state.nowSearchLoading = false
                    return .none
                }
                
                Analytics.logEvent("SerachVC_Search", parameters: [
                    "Search_Station" : state.searchQuery
                ])
                state.nowStationSearchList = []
                return .run { [name = state.searchQuery] send in
                    let result = await self.totalLoad.stationNameSearchReponse(name)
                    try await Task.sleep(for: .milliseconds(300))
                    await send(.stationSearchResult(result))
                }
                
            case .stationSearchResult(let result):
                state.nowStationSearchList = result
                state.nowSearchLoading = false
                state.filteredSearchQueryRecommendList = state.nowSearchQueryRecommendList.filter {
                    $0.queryName == state.searchQuery
                }
                
                if state.isAutoDelegateAction == nil {
                    return .none
                } else if state.isAutoDelegateAction == .plusModal {
                    let comparisonData = state.nowUpLiveData?.code == "" ? state.nowDownLiveData : state.nowUpLiveData
                    guard let index = result.firstIndex(where: {$0.line.lineCode == comparisonData?.subwayLineData.lineCode})
                    else {
                        state.dialogState = self.errorPopup(msg: "오류가 발생했어요.\n나중에 다시 시도해주세요.")
                        state.isAutoDelegateAction = nil
                        return .none
                    }
                    return .run { send in
                        try? await Task.sleep(for: .milliseconds(100))
                        await send(.searchResultTapped(index))
                    }
                } else {
                    return .run { send in
                        try? await Task.sleep(for: .milliseconds(100))
                        await send(.disposableDetailPushRequest)
                    }
                }
               
            case .searchResultTapped(let index):
                state.isAutoDelegateAction = nil
                self.delegate?.modalPresent(data: state.nowStationSearchList[index])
                return .none
                
            case .stationTapped(let model):
                state.searchQuery = model.type == .recommend ?
                    state.nowRecommendStationList[model.index] :
                    (model.type == .location ?
                        state.nowVicinityStationList[model.index].name :
                        state.filteredSearchQueryRecommendList[model.index].stationName
                    )
                state.filteredSearchQueryRecommendList = []
                state.nowSearchLoading = true
                state.isSearchMode = true
                
                return .send(.stationSearchRequest)
                
            case .disposableDetailPushRequest:
                guard  case let .disposableDetail(isUp) = state.isAutoDelegateAction,
                      let data = isUp ? state.nowUpLiveData : state.nowDownLiveData,
                       let searchIndex = state.nowStationSearchList.firstIndex(where: {$0.line.lineCode == data.subwayLineData.lineCode})
                else {
                    state.dialogState = self.errorPopup(msg: "오류가 발생했어요.\n나중에 다시 시도해주세요.")
                    state.isAutoDelegateAction = nil
                    return .none
                }
                let searchData = state.nowStationSearchList[searchIndex]
                state.isAutoDelegateAction = nil
                self.delegate?.disposableDetailPush(data: .init(upDown: data.upDown, stationName: data.stationName, lineNumber: searchData.line.rawValue, stationCode: searchData.stationCode, lineCode: searchData.line.lineCode, exceptionLastStation: "", korailCode: ""))
                return .none
                
            case .stationAddBtnTapped:
                guard let index = state.nowTappedStationIndex,
                      (state.nowUpLiveData?.code != "" || state.nowDownLiveData?.code != "")
                else {
                    state.dialogState =  self.errorPopup(msg: "실시간 데이터가 확인되지 않았어요.\n새로고침 버튼을 통해 실시간 데이터를 확인해주세요.")
                    return .none
                }
                state.searchQuery = state.nowVicinityStationList[index].name
                state.isAutoDelegateAction = .plusModal
                state.isSearchMode = true
                state.nowSearchLoading = true
                return .send(.stationSearchRequest)
                
            case .reportBtnTapped:
                guard let line = getTappedLineOrShowError(&state),
                      let index = state.nowTappedStationIndex else {
                    return .none
                }
                delegate?.reportPush(reportLine: line, stationName: state.nowVicinityStationList[index].name)
                return .none
                
            default: return .none
            }
        }
    }
}

private extension SearchFeature {
    func errorPopup(msg: String) -> ConfirmationDialogState<Action.DialogAction> {
        .init(title: {
            TextState("")
        }, actions: {
            ButtonState( action: .cancelBtnTapped) {
                TextState("확인")
            }
        }, message: {
            TextState(msg)
        })
    }
    
    func getTappedLineOrShowError(_ state: inout State) -> SubwayLineData? {
        guard let index = state.nowTappedStationIndex else { return nil }
        let tappedData = state.nowVicinityStationList[index]
        guard let line = SubwayLineData(rawValue: tappedData.lineColorName),
              (state.nowUpLiveData?.code != "" || state.nowDownLiveData?.code != "")
        else {
            state.dialogState =  self.errorPopup(msg: "실시간 데이터가 확인되지 않았어요.\n새로고침 버튼을 통해 실시간 데이터를 확인해주세요.")
            return nil
        }
        return line
    }
}

// 테스트용 State
extension SearchFeature.State {
    #if DEBUG
    public var testLastVicinitySearchTime: Date? {
        get { lastVicintySearchTime }
        set { lastVicintySearchTime = newValue }
    }
    
    var testNowSearchQueryRecommendList: [SearchQueryRecommendData] {
        get { nowSearchQueryRecommendList }
        set { nowSearchQueryRecommendList = newValue }
    }
    
    public var testIsFirst: Bool {
        get { isFirst }
        set { isFirst = newValue }
    }
    
    var testIsAutoDelegateAction: AutoDelegateAction? {
        get { isAutoDelegateAction }
        set { isAutoDelegateAction = newValue }
    }
    #endif
}
