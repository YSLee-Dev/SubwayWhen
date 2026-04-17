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
        var shouldScrollToStation: Bool = false
        @Presents var dialogState: ConfirmationDialogState<Action.DialogAction>?
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
        case scrollToStationRequest
        case scrollToStationCompleted
        case dialogAction(PresentationAction<DialogAction>)

        enum DialogAction: Equatable {
            case cancelBtnTapped
            case okBtnTapped
        }
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
                    self.trainPositionRequest(state: state)
                )

            case .stationListLoaded(let list):
                if list.isEmpty {
                    return .send(.bundleLoadFailed)
                }
                state.stationList = list
                return .run { send in
                    try? await Task.sleep(for: .milliseconds(400))
                    await send(.scrollToStationRequest)
                }

            case .trainPositionLoaded(let positions):
                state.trainPositions = positions
                state.isLoading = false
                return .none

            case .refreshBtnTapped:
                state.isLoading = true
                return self.trainPositionRequest(state: state)

            case .backBtnTapped:
                self.coordinatorDelegate?.pop()
                return .none

            case .exceptionBtnTapped:
                if state.exceptionLastStation.isEmpty { return .none }
                let msg = "\(state.exceptionLastStation)\(Strings.Realtime.exceptionDialogMessageSuffix)"
                state.dialogState = ConfirmationDialogState(title: {
                    TextState("")
                }, actions: {
                    ButtonState(action: .okBtnTapped) {
                        TextState(Strings.Realtime.exceptionDialogOk)
                    }
                    ButtonState(role: .cancel, action: .cancelBtnTapped) {
                        TextState(Strings.Common.cancel)
                    }
                }, message: {
                    TextState(msg)
                })
                return .none

            case .dialogAction(.presented(.okBtnTapped)):
                state.dialogState = nil
                state.exceptionLastStation = ""
                state.isLoading = true
                return self.trainPositionRequest(state: state)

            case .dialogAction:
                state.dialogState = nil
                return .none
                
            case .scrollToStationRequest:
                state.shouldScrollToStation = true
                return .none

            case .scrollToStationCompleted:
                state.shouldScrollToStation = false
                return .none

            case .bundleLoadFailed:
                self.coordinatorDelegate?.showBundleErrorPopupAndDismiss()
                return .none
            }
        }
        .ifLet(\.dialogState, action: \.dialogAction)
    }
}

// MARK: - Method

private extension RealtimeFeature {
    func trainPositionRequest(state: State) -> Effect<Action> {
        let subwayLine = state.subwayLine
        let isUp = state.isUp
        let exceptionLastStation = state.exceptionLastStation
        return .run { [totalLoad = self.totalLoad] send in
            let positions = await totalLoad.realtimePositionLoad(
                subwayLine: subwayLine,
                isUp: isUp,
                exceptionLastStation: exceptionLastStation
            )
            await send(.trainPositionLoaded(positions))
        }
    }
}
