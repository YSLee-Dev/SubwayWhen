//
//  SearchStationResultView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 12/10/24.
//

import SwiftUI
import ComposableArchitecture

struct SearchStationResultView: View {
    @Binding var store: StoreOf<SearchFeature>
    
    var body: some View {
        MainStyleViewInSUI {
            LazyVStack(alignment: .leading, spacing: 5) {
                Text("총 \(self.store.nowStationSearchList.count)개의 검색 결과")
                    .font(.system(size: ViewStyle.FontSize.largeSize, weight: .heavy))
                    .padding(.bottom, 10)
                
                if self.store.nowSearchLoading {
                    ExpandedViewInSUI(alignment: .center) {
                        ProgressView()
                            .tint(Color("AppIconColor"))
                            .frame(height: 33)
                            .padding(.bottom, 15)
                    }
                } else {
                    if self.store.nowStationSearchList.isEmpty {
                        ExpandedViewInSUI(alignment: .center) {
                            Text(self.store.searchQuery.isEmpty ? "지하철역 이름을 입력해주세요." : "검색된 지하철역이 없어요.")
                                .font(.system(size: ViewStyle.FontSize.mediumSize, weight: .bold))
                                .padding(.vertical, 15)
                        }
                    } else {
                        ForEach(self.store.nowStationSearchList, id: \.lineNumber) { data in
                            AnimationButtonInSUI(buttonView: {
                                HStack(spacing: 10) {
                                    StationTitleViewInSUI(title: data.useLine, lineColor: data.lineNumber.rawValue, size: 60, isFill: true)
                                    
                                    Text(data.stationName)
                                        .font(.system(size: ViewStyle.FontSize.mediumSize, weight: .bold))
                                    
                                    Spacer()
                                }
                            }, tappedAction: {
                                
                            })
                        }
                        .animation(.easeInOut(duration: 0.3) ,value: self.store.nowVicinityStationList)
                    }
                }
            }
            .padding(15)
            .animation(.easeInOut(duration: 0.3) ,value: self.store.nowSearchLoading)
        }
    }
}

#Preview {
    SearchStationResultView(store: .constant(.init(initialState: .init(), reducer: {SearchFeature()})))
}
