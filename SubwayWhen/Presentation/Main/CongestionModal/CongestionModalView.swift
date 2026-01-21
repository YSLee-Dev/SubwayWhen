//
//  CongestionModalView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 1/7/26.
//

import SwiftUI

import ComposableArchitecture
import Charts

struct CongestionModalView: View {
    
    // MARK: - Properties
    
    @State private var store: StoreOf<CongestionModalFeature>
    @State private var selectedHour: Int?
    
    // MARK: - LifeCycle
    
    init(store: StoreOf<CongestionModalFeature>) {
        self.store = store
    }
    
    // MARK: - View
    
    var body: some View {
        VStack(spacing: 20) {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 10) {
                    ForEach(self.store.availableStationList, id: \.self) { station in
                        let isSelected = station == self.store.selectedStation
                        
                        AnimationButtonInSUI(buttonView: {
                            Text(station)
                                .font(.system(size: ViewStyle.FontSize.smallSize, weight: isSelected ? .bold : .medium))
                                .padding(.horizontal, 10)
                        }, tappedAction: {
                            self.store.send(.stationBtnTapped(station: station))
                            self.selectedHour = nil
                        })
                        .overlay {
                            RoundedRectangle(cornerRadius:  ViewStyle.Layer.radius)
                                .strokeBorder(Color("AppIconColor"), lineWidth: isSelected ? 1 : 0)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .frame(height: 40)
            
            Chart {
                ForEach(self.store.congestionData, id: \.hour) { data in
                    LineMark(
                        x: .value("hour", data.hour),
                        y: .value("congestion", data.congestion.percent)
                    )
                    .foregroundStyle(Color("AppIconColor"))
                    .interpolationMethod(.catmullRom)
                }
                
                if let currentData = self.store.congestionData.first(where: { $0.hour == self.store.nowHour }) {
                    PointMark(
                        x: .value("hour", currentData.hour),
                        y: .value("congestion", currentData.congestion.percent)
                    )
                    .foregroundStyle(.red)
                    .shadow(color: Color.black.opacity(0.4), radius: 5)
                    .symbolSize(75)
                    .annotation(
                        position: .top,
                        spacing: 5,
                        overflowResolution: .init(x: .disabled, y: .padScale)
                    ) {
                        if self.selectedHour == nil {
                            self.congestionAnnotation(value: "\(currentData.congestion.percent)%")
                                .frame(minWidth: 60)
                        }
                    }
                }
                
                if let selectedHour = self.selectedHour,
                   let currentData = self.store.congestionData.first(where: { $0.hour == selectedHour }) {
                    RuleMark(x: .value("selectedHour", selectedHour))
                        .foregroundStyle(.gray.opacity(0.5))
                        .annotation(
                            position: .top,
                            spacing: 0,
                            overflowResolution: .init(x: .disabled, y: .fit(to: .chart))
                        ) {
                            self.congestionAnnotation(value: "\(selectedHour)\(Strings.Common.hour) · \(currentData.congestion.percent)%")
                                .frame(minWidth: 120)
                        }
                }
            }
            .animation(.smooth, value: self.store.selectedStation)
            .animation(.smooth, value: self.selectedHour)
            .chartXAxis {
                AxisMarks(values: [0, 3, 6, 9, 12, 15, 18, 21, 23]) { value in
                    if let hour = value.as(Int.self) {
                        AxisValueLabel {
                            Text("\(hour)\(Strings.Common.hour)")
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(values: .stride(by: 30)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let percent = value.as(Int.self) {
                            Text("\(percent)%")
                        }
                    }
                }
            }
            .chartGesture { chart in
                SpatialTapGesture()
                    .onEnded { value in
                        let xPosition = value.location.x
                        guard let selectedHour: Int = chart.value(atX: xPosition) else { return }
                        
                        if selectedHour == self.store.nowHour {
                            self.selectedHour = nil
                        } else {
                            self.selectedHour = selectedHour
                        }
                    }
            }
        }
        .padding(.bottom, 20)
        .onAppear {
            self.store.send(.onAppear)
        }
        .onDisappear {
            self.store.send(.onDisappear)
        }
    }
}

// MARK: - Methods

private extension CongestionModalView {
    @ViewBuilder
    func congestionAnnotation(value: String) -> some View {
        Text(value)
            .font(.system(size: ViewStyle.FontSize.smallSize, weight: .bold))
            .padding(5)
            .background {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color("MainColor"))
            }
    }
}
