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
                title: self.store.subwayLine.useLine,
                lineColor: self.store.subwayLine.rawValue,
                size: 75,
                isFill: true
            )
            .padding(.vertical, ViewStyle.padding.mainStyleViewTB)

            if self.store.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(self.store.stationList, id: \.stationId) { station in
                    let position = self.store.trainPositions.first { $0.statnId == station.stationId }
                    RealtimeStationRowView(
                        stationName: station.stationName,
                        isSelected: station.stationName == self.store.stationName,
                        position: position,
                        subwayLine: self.store.subwayLine
                    )
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(self.store.subwayLine.useLine)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    self.store.send(.refreshBtnTapped)
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundStyle(Color(uiColor: .label))
                }
            }
        }
        .onAppear {
            self.store.send(.onAppear)
        }
    }
}

#Preview {
    RealtimeView(
        store: .init(
            initialState: RealtimeFeature.State(subwayLine: .two, stationName: "강남", isUp: false),
            reducer: { RealtimeFeature() }
        )
    )
}
