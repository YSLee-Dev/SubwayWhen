//
//  SearchView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 12/2/24.
//

import SwiftUI
import ComposableArchitecture

struct SearchView: View {
    @State private var store: StoreOf<SearchFeature>
    
    init(store: StoreOf<SearchFeature>) {
        self.store = store
    }
    
    var body: some View {
        NavigationBarScrollViewInSUI(title: "검색") {
            VStack(spacing: 20) {
                AnimationButtonInSUI(
                    buttonViewAlignment: .leading,
                    buttonView: {
                        Text("🔍 지하철역을 검색하세요.")
                            .foregroundColor(.gray)
                            .font(.system(size: ViewStyle.FontSize.mediumSize, weight: .light))
                            .frame(height: 25)
                            .padding(.horizontal, 15)
                    }
                ) {
                    print("SearchBar Tapped")
                }
                
                MainStyleViewInSUI {
                    VStack(spacing: 0) {
                        HStack {
                            if self.store.state.nowTappedStationIndex == nil {
                                Text("현재 위치와 가까운 지하철역을 확인할 수 있어요.")
                                    .font(.system(size: ViewStyle.FontSize.mediumSize, weight: .bold))
                            }
                            Spacer()
                        }
                        .padding(.init(top: 20, leading: 0, bottom: 10, trailing: 0))
                        
                        ScrollView(.horizontal) {
                            LazyHStack(spacing: 0) {
                                ForEach(Array(zip(self.store.state.nowVicinityStations, self.store.state.nowVicinityStations.indices)), id: \.1) { data, index in
                                    if self.store.state.nowTappedStationIndex  == nil {
                                        AnimationButtonInSUI(buttonView: {
                                            StationTitleViewInSUI(title: data.name, lineColor: data.lineColorName, size: 50, isFill: true, fontSize: ViewStyle.FontSize.smallSize)
                                        }) {
                                            self.store.send(.stationTapped(index))
                                        }
                                    } else if self.store.state.nowTappedStationIndex  != nil && self.store.state.nowTappedStationIndex  != index {
                                        AnimationButtonInSUI(buttonView: {
                                            VStack(spacing: 3) {
                                                RoundedRectangle(cornerRadius: 3)
                                                    .fill(Color(data.lineColorName))
                                                    .frame(minWidth: 50)
                                                    .frame(height: 7.5)
                                                
                                                Text(data.name)
                                                    .font(.system(size: ViewStyle.FontSize.smallSize, weight: .medium))
                                            }
                                        }) {
                                            self.store.send(.stationTapped(index))
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.bottom, self.store.nowTappedStationIndex == nil ? 15 : 0)
                        .offset(y: self.store.nowTappedStationIndex == nil ? 0 : -10)
                        
                        if let index = self.store.nowTappedStationIndex {
                            let tappedData = self.store.nowVicinityStations[index]
                            
                            HStack(spacing: 0) {
                                VStack(alignment: .leading) {
                                    Spacer()
                                        .frame(height: 10)
                                    
                                    ZStack(alignment: .leading){
                                        RoundedRectangle(cornerRadius: ViewStyle.Layer.radius)
                                            .fill(Color(tappedData.lineColorName))
                                            .frame(height: 5)
                                            .scaleEffect(y: self.store.state.nowLiveDataLoading[0] ? 0.2 : 1)
                                        
                                        StationTitleViewInSUI(title: "", lineColor: tappedData.lineColorName, size: 12.5, isFill: false)
                                            .opacity(self.store.state.nowLiveDataLoading[0] ? 0 : 1)
                                    }
                                    .overlay {
                                        if !self.store.state.nowLiveDataLoading[0] {
                                            let code = self.store.nowUpLiveData?.trainCode ?? "99"
                                            HStack {
                                                if code == "0" || code == "1" || code == "2" {
                                                    Spacer()
                                                }
                                                Text(FixInfo.saveSetting.detailVCTrainIcon)
                                                    .padding(.bottom, 20)
                                                    .padding(.trailing, code == "0" ? 10 : 0)
                                                    .padding(.leading, code == "4" ? -15 : -5)
                                                
                                                if code == "4" || code == "5" || code == "99" {
                                                    Spacer()
                                                }
                                            }
                                        }
                                    }
                                    
                                    let backStation = self.store.state.nowLiveDataLoading[0] ? "🔄" : self.store.nowUpLiveData?.previousStation ?? ""
                                    Text(backStation)
                                        .font(.system(size: ViewStyle.FontSize.smallSize))
                                    
                                    Spacer()
                                }
                                .animation(.easeInOut(duration: 0.3), value: self.store.state.nowLiveDataLoading[0])
                                .offset(x: 7.5)
                                
                                StationTitleViewInSUI(title: tappedData.name, lineColor: tappedData.lineColorName,  size: 50, isFill: true, fontSize: ViewStyle.FontSize.smallSize) 
                                    .onTapGesture {
                                        self.store.send(.stationTapped(nil)) 
                                    }
                                
                                VStack(alignment: .trailing) {
                                    Spacer()
                                    
                                    ZStack(alignment: .trailing){
                                        RoundedRectangle(cornerRadius: ViewStyle.Layer.radius)
                                            .fill(Color(tappedData.lineColorName))
                                            .frame(height: 5)
                                            .scaleEffect(y: self.store.state.nowLiveDataLoading[1] ? 0.2 : 1)
                                        
                                        StationTitleViewInSUI(title: "", lineColor: tappedData.lineColorName, size: 12.5, isFill: false)
                                            .opacity(self.store.state.nowLiveDataLoading[1] ? 0 : 1)
                                    }
                                    .overlay {
                                        if !self.store.state.nowLiveDataLoading[1] {
                                            let code = self.store.nowDownLiveData?.trainCode ?? "99"
                                            HStack {
                                                if code == "4" || code == "5" || code == "99" {
                                                    Spacer()
                                                }
                                               
                                                Text(FixInfo.saveSetting.detailVCTrainIcon)
                                                    .padding(.bottom, 20)
                                                    .padding(.trailing, code == "4" ? -15 : 0)
                                                    .padding(.leading, code == "0" ? 10 : 0)
                                                
                                                if code == "0" || code == "1" || code == "2" {
                                                    Spacer()
                                                }
                                            }
                                        }
                                    }
                                    
                                    
                                    let backStation = self.store.state.nowLiveDataLoading[1] ? "🔄" : self.store.nowDownLiveData?.previousStation ?? ""
                                    Text(backStation)
                                        .font(.system(size: ViewStyle.FontSize.mediumSmallSize))
                                }
                                .animation(.easeInOut(duration: 0.3), value: self.store.state.nowLiveDataLoading[1])
                                .offset(x: -7.5, y: 10)
                            }
                            .padding(.bottom, 20)
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: self.store.state.nowTappedStationIndex)
                    .padding(.horizontal, 15)
                }
            }
            .padding(.top, 12.5)
            .onAppear {
                self.store.send(.onAppear)
            }
        }
    }
}

#Preview {
    SearchView(store: .init(initialState: .init(), reducer: {SearchFeature()}))
}
