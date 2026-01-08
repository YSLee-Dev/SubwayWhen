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
        VStack {
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
            
            Spacer()
            Text("그래프")
            Spacer()
        }
        .onAppear {
            self.store.send(.onAppear)
        }
        .onDisappear {
            self.store.send(.onDisappear)
        }
    }
}
