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
        VStack(spacing: 0) {
            StationTitleViewInSUI(
                title: store.subwayLine.useLine,
                lineColor: store.subwayLine.rawValue,
                size: 75,
                isFill: true
            )
            .padding(.vertical, ViewStyle.padding.mainStyleViewTB)

            if store.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(store.stationList, id: \.stationId) { station in
                    let position = store.trainPositions.first { $0.statnId == station.stationId }
                    RealtimeStationRowView(
                        stationName: station.stationName,
                        isSelected: station.stationName == store.stationName,
                        position: position,
                        subwayLine: store.subwayLine
                    )
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(store.subwayLine.useLine)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.send(.refreshBtnTapped)
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundStyle(Color(uiColor: .label))
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    RealtimeView(
        store: .init(
            initialState: RealtimeFeature.State(subwayLine: .two, stationName: "강남"),
            reducer: { RealtimeFeature() }
        )
    )
}
