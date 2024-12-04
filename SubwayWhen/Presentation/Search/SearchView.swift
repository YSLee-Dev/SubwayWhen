//
//  SearchView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 12/2/24.
//

import SwiftUI

struct SearchView: View {
    // 비지니스 로직 구현 전 임시 temp
    let tempArrivalData: [RealtimeStationArrival] = [
        .init(upDown: "상행", arrivalTime: "3분", previousStation: "고속터미널", subPrevious: "전전역 도착", code: "3", subWayId: "1003", stationName: "교대", lastStation: "구파발", lineNumber: "03호선", isFast: nil, backStationId: "교대 전역", nextStationId: "교대 다음역", trainCode: "99"),
        .init(upDown: "내선순환", arrivalTime: "9분", previousStation: "사당", subPrevious: "4전역 ", code: "99", subWayId: "1002", stationName: "강남", lastStation: "구파발", lineNumber: "02호선", isFast: nil, backStationId: "강남 전역", nextStationId: "강남 다음역", trainCode: "1"),
        .init(upDown: "하행", arrivalTime: "4분", previousStation: "구반포", subPrevious: "3전역 ", code: "99", subWayId: "1009", stationName: "고속터미널", lastStation: "김포공항", lineNumber: "09호선", isFast: nil, backStationId: "고속터미널 전역", nextStationId: "고속터미널 다음역", trainCode: "99"),
        .init(upDown: "하행", arrivalTime: "곧 도착", previousStation: "사당", subPrevious: "전역출발 ", code: "5", subWayId: "1007", stationName: "반포", lastStation: "온수", lineNumber: "07호선", isFast: nil, backStationId: "사당 전역", nextStationId: "사당 다음역", trainCode: "1"),
    ]
    
    // 비지니스 로직 구현 전 임시
    @State private var tempTappedIndex: Int? = nil
    
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
                            if self.tempTappedIndex == nil {
                                Text("현재 위치와 가까운 지하철역을 확인할 수 있어요.")
                                    .font(.system(size: ViewStyle.FontSize.mediumSize, weight: .bold))
                            }
                            Spacer()
                        }
                        .padding(.init(top: 20, leading: 0, bottom: 10, trailing: 0))
                        
                        ScrollView(.horizontal) {
                            LazyHStack(spacing: 0) {
                                ForEach(Array(zip(self.tempArrivalData, self.tempArrivalData.indices)), id: \.1) { data, index in
                                    if self.tempTappedIndex == nil {
                                        AnimationButtonInSUI(buttonView: {
                                            StationTitleViewInSUI(title: data.stationName, lineColor: data.lineNumber ?? "", size: 50, isFill: true, fontSize: ViewStyle.FontSize.smallSize)
                                        }) {
                                            self.tempTappedIndex = index
                                        }
                                    } else if self.tempTappedIndex != nil && self.tempTappedIndex != index {
                                        AnimationButtonInSUI(buttonView: {
                                            VStack(spacing: 3) {
                                                RoundedRectangle(cornerRadius: 3)
                                                    .fill(Color(data.lineNumber ?? ""))
                                                    .frame(minWidth: 50)
                                                    .frame(height: 7.5)
                                                
                                                Text(data.stationName)
                                                    .font(.system(size: ViewStyle.FontSize.smallSize, weight: .medium))
                                            }
                                        }) {
                                            self.tempTappedIndex = index
                                        }
                                    }
                                }
                            }
                        }
                        .offset(y: self.tempTappedIndex == nil ? 0 : -10)
                        
                        if let index = self.tempTappedIndex {
                            let data = self.tempArrivalData[index]
                            ZStack {
                                RoundedRectangle(cornerRadius: ViewStyle.Layer.radius)
                                    .fill(Color(data.lineNumber ?? ""))
                                    .frame(height: 5)
                                
                                StationTitleViewInSUI(title: data.stationName, lineColor: data.lineNumber ?? "", size: 50, isFill: true, fontSize: ViewStyle.FontSize.smallSize)
                                
                                HStack {
                                    Text(data.previousStation ?? "")
                                        .font(.system(size: ViewStyle.FontSize.smallSize, weight: .medium))
                                    Spacer()
                                    Text(data.previousStation ?? "")
                                        .font(.system(size: ViewStyle.FontSize.smallSize, weight: .medium))
                                }
                                .padding(.top, 30)
                                
                                HStack {
                                    StationTitleViewInSUI(title: "", lineColor: data.lineNumber ?? "", size: 12.5, isFill: false)
                                    Spacer()
                                    StationTitleViewInSUI(title: "", lineColor: data.lineNumber ?? "", size: 12.5, isFill: false)
                                }
                                
                                HStack {
                                    Text(FixInfo.saveSetting.detailVCTrainIcon)
                                        .scaleEffect(x: -1, y: 1)
                                    Spacer()
                                    Text(FixInfo.saveSetting.detailVCTrainIcon)
                                }
                                .padding(.bottom, 25)
                            }
                            .padding(.bottom, 15)
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: self.tempTappedIndex)
                    .padding(.horizontal, 15)
                }
            }
            .padding(.top, 12.5)
        }
    }
}

#Preview {
    SearchView()
}
