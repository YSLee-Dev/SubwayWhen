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
            }
            .animation(.smooth, value: self.store.selectedStation)
            .chartXAxis {
                AxisMarks(values: .stride(by: 3)) { value in
                    if let hour = value.as(Int.self) {
                        AxisValueLabel {
                            Text("\(hour)시")
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
