//
//  CongestionModalView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 1/7/26.
//

import SwiftUI

import ComposableArchitecture

struct CongestionModalView: View {
    
    // MARK: - Properties
    
    @State private var store: StoreOf<CongestionModalFeature>
    
    // MARK: - LifeCycle
    
    init(store: StoreOf<CongestionModalFeature>) {
        self.store = store
    }
    
    // MARK: - View
    
    var body: some View {
        Text("CongestionModalView")
            .onDisappear {
                self.store.send(.onDisappear)
            }
    }
}
