//
//  CongestionModalFeature.swift
//  SubwayWhen
//
//  Created by 이윤수 on 1/7/26.
//

import Foundation

import ComposableArchitecture

@Reducer
struct CongestionModalFeature {
    
    // MARK: - State
    
    @ObservableState
    struct State: Equatable {
        var selectedStation = FixInfo.saveSetting.mainCongestionBaseStaton
        var availableStationList: [String] = []
    }
    
    // MARK: - Action
    
    enum Action: Equatable {
        case onAppear
        case onDisappear
        case closeBtnTapped
    }
    
    // MARK: - Properties
    
    @Dependency(\.congestionManager) private var congestionManager
    weak var delegate: CongestionViewAction?
    
    // MARK: - Reducer
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.availableStationList = self.congestionManager.getAvailableStations()
                return .none
                
            case .onDisappear:
                self.delegate?.didDisappear()
                return .none
                
            case .closeBtnTapped:
                self.delegate?.dismiss()
                return .none
                
            default: return .none
            }
        }
    }
}
