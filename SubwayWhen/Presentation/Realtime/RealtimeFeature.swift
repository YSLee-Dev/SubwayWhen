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

    // MARK: - State

    @ObservableState
    struct State: Equatable {

    }

    // MARK: - Action

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
    }

    // MARK: - Reducer

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .onAppear:
                return .none
            }
        }
    }
}
