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
                            .font(.system(size: ViewStyle.FontSize.largeSize, weight: .light))
                            .frame(height: 25)
                            .padding(.horizontal, 15)
                    }
                ) {
                    print("SearchBar Tapped")
                }
                
                if self.store.state.locationAuth {
                    SearchVicinityView(store: self.$store)
                } else {
                    MainStyleViewInSUI {
                        VStack(spacing: 15) {
                            ExpandedViewInSUI(alignment: .leading) {
                                Text("현재 위치와 가장 가까운 지하철역의\n정보를 확인할 수 있어요.")
                                    .font(.system(size: ViewStyle.FontSize.mainTitleMediumSize, weight: .heavy))
                            }
                            
                            AnimationButtonInSUI(
                                bgColor: Color("AppIconColor"), tappedBGColor: Color("AppIconColor"), buttonView: {
                                    Text("확인하기")
                                        .foregroundStyle(.white)
                                        .font(.system(size: ViewStyle.FontSize.smallSize))
                                }) {
                                    
                                }
                                .frame(width: 150)
                        }
                        .padding(.init(top: 20, leading: 15, bottom: 20, trailing: 15))
                    }
                    .animation(.smooth(duration: 0.3), value: self.store.state.nowTappedStationIndex)
                }
                
                SearchWordRecommendView(store: self.$store)
                
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
