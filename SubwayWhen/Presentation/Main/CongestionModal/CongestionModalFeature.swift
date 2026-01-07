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
        
    }
    
    // MARK: - Action
    
    enum Action: Equatable {
        case onDisappear
        case closeBtnTapped
    }
    
    // MARK: - Properties
    
    weak var delegate: CongestionViewAction?
    
    // MARK: - Reducer
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
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
