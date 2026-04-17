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
        
        ScrollViewReader { proxy in
            NavigationBarScrollViewInSUI(
                title: self.store.subwayLine.rawValue.filter {$0 != "0"} + " \(Strings.Realtime.realTime)",
                isLargeTitleHidden: true,
                backBtnTapped: {
                    self.store.send(.backBtnTapped)
                },
                backBtnIcon: "arrow.left",
                trailingBtnIcon: "arrow.triangle.2.circlepath",
                trailingBtnTapped: {
                    self.store.send(.refreshBtnTapped)
                }
            ) {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(Color(uiColor: .init(named: self.store.subwayLine.rawValue) ?? .black))
                    .frame(height: 160)
                    .overlay {
                        VStack(spacing: 20) {
                            ExpandedViewInSUI(alignment: .center) {
                                StationTitleViewInSUI(
                                    title: self.store.subwayLine.useLine,
                                    lineColor: self.store.subwayLine.rawValue,
                                    size: 75,
                                    isFill: false
                                )
                            }
                            
                            UpDownExceptionViewInSUI(
                                upDown: self.store.isUp ? Strings.Common.up : Strings.Common.down,
                                exceptionLastStation: self.store.exceptionLastStation
                            ) {
                                self.store.send(.exceptionBtnTapped)
                            }
                        }
                        .padding(20)
                    }
                
                LazyVStack(spacing: 0) {
                    ForEach(self.store.stationList, id: \.stationId) { station in
                        let position = self.store.trainPositions.first { $0.statnId == station.stationId }
                        RealtimeStationRowView(
                            stationName: station.stationName,
                            isSelected: station.stationName == self.store.stationName,
                            position: position,
                            subwayLine: self.store.subwayLine
                        )
                        .id(station.stationId)
                    }
                }
                .padding(.top, 12.5)
            }
            .onChange(of: self.store.shouldScrollToStation) { _, shouldScroll in
                guard shouldScroll,
                      let target = self.store.stationList.first(where: { $0.stationName == self.store.stationName })
                else { return }
                
                withAnimation(.smooth) {
                    proxy.scrollTo(target.stationId, anchor: .center)
                    self.store.send(.scrollToStationCompleted)
                }
            }
        }
        .overlay {
            if self.store.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .animation(.smooth(duration: 0.3), value: self.store.trainPositions)
        .confirmationDialog(self.$store.scope(state: \.dialogState, action: \.dialogAction))
        .onAppear {
            self.store.send(.onAppear)
        }
        .onDisappear {
            self.store.send(.onDisappear)
        }
    }
}

#Preview {
    RealtimeView(
        store: .init(
            initialState: RealtimeFeature.State(subwayLine: .two, stationName: "강남", isUp: false, exceptionLastStation: ""),
            reducer: { RealtimeFeature() }
        )
    )
}
