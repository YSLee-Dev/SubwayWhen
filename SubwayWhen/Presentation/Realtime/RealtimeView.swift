//
//  RealtimeView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 4/9/26
//

import SwiftUI
import ComposableArchitecture

struct RealtimeView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<RealtimeFeature>

    // MARK: - View

    var body: some View {
        EmptyView()
            .onAppear {
                store.send(.onAppear)
            }
    }
}

#Preview {
    RealtimeView(
        store: .init(
            initialState: RealtimeFeature.State(),
            reducer: { RealtimeFeature() }
        )
    )
}
