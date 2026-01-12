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
        var congestionData: [HourlyCongestionData] = []
        var nowHour = 0
    }
    
    // MARK: - Action
    
    enum Action: Equatable {
        case onAppear
        case onDisappear
        case closeBtnTapped
        case stationBtnTapped(station: String)
        case congestionDataReuqest
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
                return .send(.congestionDataReuqest)
                
            case .onDisappear:
                self.delegate?.didDisappear()
                return .none
                
            case .closeBtnTapped:
                self.delegate?.dismiss()
                return .none
                
            case .stationBtnTapped(let station):
                if state.selectedStation == station {return .none}
                
                state.selectedStation = station
                FixInfo.saveSetting.mainCongestionBaseStaton = station
                self.delegate?.congestionStationChanged()
                return .send(.congestionDataReuqest)
                
            case .congestionDataReuqest:
                state.nowHour = Calendar.current.component(.hour, from: .now)
                state.congestionData = self.congestionManager.getCongestions(station: state.selectedStation) ?? []
                return .none
            }
        }
    }
}
