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
    var tfFocus: FocusState<Bool>.Binding
    
    var body: some View {
        MainStyleViewInSUI {
            LazyVStack(alignment: .leading, spacing: 5) {
                Text(self.store.nowSearchLoading ? "지하철역을 찾는 중이에요 🔍" : self.store.searchQuery.isEmpty ? "지하철역을 입력해주세요." : "총 \(self.store.nowStationSearchList.count)개의 검색 결과")
                    .font(.system(size: ViewStyle.FontSize.largeSize, weight: .heavy))
                    .padding(.bottom, 10)
                
                if self.store.nowSearchLoading {
                    ExpandedViewInSUI(alignment: .center) {
                        ProgressView()
                            .tint(Color("AppIconColor"))
                            .frame(height: 33)
                            .padding(.vertical, 7.5)
                    }
                } else {
                    if self.store.nowStationSearchList.isEmpty {
                        ExpandedViewInSUI(alignment: .center) {
                            Text(self.store.searchQuery.isEmpty ? "💬" : "검색된 지하철역이 없어요.")
                                .font(.system(size: ViewStyle.FontSize.mediumSize, weight: .bold))
                                .padding(.vertical, 15)
                        }
                    } else {
                        ForEach(Array(zip(self.store.nowStationSearchList, self.store.nowStationSearchList.indices)), id: \.1) { data, index in
                            AnimationButtonInSUI(bgColor: Color.gray.opacity(0.1), tappedBGColor: Color.gray.opacity(0.01), buttonView: {
                                HStack(spacing: 10) {
                                    StationTitleViewInSUI(title: data.line.useLine, lineColor: data.line.rawValue, size: 60, isFill: true)
                                    
                                    Text(data.stationName)
                                        .font(.system(size: ViewStyle.FontSize.mediumSize, weight: .bold))
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 5)
                            }, tappedAction: {
                                self.tfFocus.wrappedValue = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    self.store.send(.searchResultTapped(index))
                                }
                            })
                        }
                        .padding(.vertical, 5)
                        .animation(.easeInOut(duration: 0.3) ,value: self.store.nowVicinityStationList)
                    }
                }
            }
            .padding(15)
            .animation(.easeInOut(duration: 0.3) ,value: self.store.nowSearchLoading)
        }
    }
}
//
//#Preview {
//    SearchStationResultView(store: .constant(.init(initialState: .init(), reducer: {SearchFeature()})), tfFocus: .constant(false))
//}
