//
//  SearchFeature.swift
//  SubwayWhen
//
//  Created by 이윤수 on 12/4/24.
//

import Foundation

import ComposableArchitecture
import FirebaseAnalytics

@Reducer
class SearchFeature {
    
    @ObservableState
    struct State: Equatable {
        
    }
    
    enum Action: Equatable {
        
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
}
