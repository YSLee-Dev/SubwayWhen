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
    @FocusState private var tfFocus: Bool
    
    init(store: StoreOf<SearchFeature>) {
        self.store = store
    }
    
    var body: some View {
        NavigationBarScrollViewInSUI(title: "검색") {
            VStack(spacing: 20) {
                HStack(spacing: 10) {
                    MainStyleViewInSUI {
                        TextField(text: self.$store.searchQuery) {
                            Text("🔍 지하철역을 검색하세요.")
                                .foregroundColor(.gray)
                                .font(.system(size: ViewStyle.FontSize.largeSize, weight: .light))
                        }
                        .padding(15)
                        .focused(self.$tfFocus)
                        .onChange(of: self.tfFocus) { _, new in
                            self.store.send(.isSearchMode(new))
                        }
                    }
                    if self.store.isSearchMode {
                        Button {
                            self.store.send(.isSearchMode(false))
                            self.tfFocus = false
                        } label: {
                            Text("닫기")
                                .font(.system(size: ViewStyle.FontSize.mediumSize, weight: .light))
                        }
                    }
                }
                
                if self.store.state.isSearchMode {
                    SearchStationResultView(store: self.$store)
                } else {
                    if self.store.state.locationAuth {
                        SearchVicinityView(store: self.$store)
                    } else {
                        MainStyleViewInSUI {
                            VStack(spacing: 15) {
                                ExpandedViewInSUI(alignment: .leading) {
                                    Text("현재 위치와 가장 가까운 지하철역의\n정보를 확인할 수 있어요.")
                                        .font(.system(size: ViewStyle.FontSize.largeSize, weight: .heavy))
                                }
                                
                                AnimationButtonInSUI(
                                    bgColor: Color("AppIconColor"), tappedBGColor: Color("AppIconColor"), buttonView: {
                                        Text("확인하기")
                                            .foregroundStyle(.white)
                                            .font(.system(size: ViewStyle.FontSize.smallSize))
                                    }) {
                                        self.store.send(.locationAuthRequest)
                                    }
                                    .frame(width: 150)
                            }
                            .padding(15)
                        }
                        .animation(.smooth(duration: 0.3), value: self.store.state.nowTappedStationIndex)
                    }
                }
                
                SearchWordRecommendView(store: self.$store)
            }
            .animation(.easeInOut(duration: 0.3), value: self.store.isSearchMode)
            .padding(.top, 12.5)
            .onAppear {
                self.store.send(.onAppear)
            }
            .confirmationDialog(self.$store.scope(state: \.dialogState, action: \.dialogAction))
        }
    }
}

#Preview {
    SearchView(store: .init(initialState: .init(), reducer: {SearchFeature()}))
}
