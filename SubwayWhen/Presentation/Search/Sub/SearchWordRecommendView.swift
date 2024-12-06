//
//  SearchWordRecommendView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 12/5/24.
//

import SwiftUI
import ComposableArchitecture

struct SearchWordRecommendView: View {
    @Binding var store: StoreOf<SearchFeature>
    
    var body: some View {
        MainStyleViewInSUI {
            VStack(spacing: 15) {
                HStack {
                    Text("자주 검색되는 지하철역")
                        .font(.system(size: ViewStyle.FontSize.mediumSize, weight: .heavy))
                    Spacer()
                }
            
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 15), GridItem(.flexible(), spacing: 15)]) {
                    ForEach(self.store.state.recommendStationList, id: \.self) { data in
                        AnimationButtonInSUI(bgColor: Color.gray.opacity(0.2), tappedBGColor: Color.gray.opacity(0.1), buttonView: {
                            HStack {
                                Spacer()
                                Text(data)
                                    .foregroundStyle(.black.opacity(0.8))
                                    .font(.system(size: ViewStyle.FontSize.smallSize, weight: .semibold))
                                Spacer()
                            }
                            .padding(5)
                        }, tappedAction: {
                            
                        })
                        .padding(.vertical, 5)
                    }
                }
            }
            .padding(.init(top: 20, leading: 15, bottom: 20, trailing: 15))
        }
        .padding(.bottom, 20)
    }
}


#Preview {
    SearchWordRecommendView(store: .constant(.init(initialState: .init(), reducer: {SearchFeature()})))
}
