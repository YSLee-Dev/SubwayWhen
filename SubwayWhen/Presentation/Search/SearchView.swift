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
                    SearchVicinityView(store: self.$store)
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
