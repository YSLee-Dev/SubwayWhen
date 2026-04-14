//
//  RealtimeFeature.swift
//  SubwayWhen
//
//  Created by 이윤수 on 4/9/26
//

import ComposableArchitecture

@Reducer
struct RealtimeFeature {

    // MARK: - Dependency

    weak var coordinatorDelegate: RealtimeCoordinatorProtocol?

    @Dependency(\.totalLoad) private var totalLoad

    // MARK: - State

    @ObservableState
    struct State: Equatable {
        let subwayLine: SubwayLineData
        let stationName: String
        let isUp: Bool
        var exceptionLastStation: String
        var stationList: [DetailStationId] = []
        var trainPositions: [RealtimeTrainPosition] = []
        var isLoading: Bool = false
    }

    // MARK: - Action

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case backBtnTapped
        case exceptionBtnTapped
        case stationListLoaded([DetailStationId])
        case trainPositionLoaded([RealtimeTrainPosition])
        case refreshBtnTapped
        case bundleLoadFailed
    }

    // MARK: - Reducer

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .onAppear:
                state.isLoading = true
                let subwayLine = state.subwayLine
                let isUp = state.isUp
                return .merge(
                    .run { [totalLoad = self.totalLoad] send in
                        let list = totalLoad.stationIdList(subwayLine: subwayLine, isUp: isUp)
                        await send(.stationListLoaded(list))
                    },
                    self.trainPositionRequest(subwayLine: subwayLine)
                )

            case .stationListLoaded(let list):
                if list.isEmpty {
                    return .send(.bundleLoadFailed)
                }
                state.stationList = list
                return .none

            case .trainPositionLoaded(let positions):
                state.trainPositions = positions
                state.isLoading = false
                return .none

            case .refreshBtnTapped:
                state.isLoading = true
                return self.trainPositionRequest(subwayLine: state.subwayLine)

            case .backBtnTapped:
                self.coordinatorDelegate?.pop()
                return .none

            case .exceptionBtnTapped:
                self.coordinatorDelegate?.showExceptionStationSheet()
                return .none

            case .bundleLoadFailed:
                self.coordinatorDelegate?.showBundleErrorPopupAndDismiss()
                return .none
            }
        }
    }
}

// MARK: - Method

private extension RealtimeFeature {
    func trainPositionRequest(subwayLine: SubwayLineData) -> Effect<Action> {
        .run { [totalLoad = self.totalLoad] send in
            let positions = await totalLoad.realtimePositionLoad(subwayLine: subwayLine)
            await send(.trainPositionLoaded(positions))
        }
    }
}
