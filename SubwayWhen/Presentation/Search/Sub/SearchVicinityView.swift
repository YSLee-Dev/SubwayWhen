//
//  SearchVicinityView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 12/5/24.
//

import SwiftUI
import ComposableArchitecture

struct SearchVicinityView: View {
    @Binding var store: StoreOf<SearchFeature>
    
    var body: some View {
        MainStyleViewInSUI {
            VStack(spacing: 0) {
                ExpandedViewInSUI(alignment: .leading)  {
                    VStack(alignment: .leading) {
                        Text("가까운 지하철역 찾기")
                            .font(.system(size: ViewStyle.FontSize.largeSize, weight: .bold))
                        Text("역을 누르면 실시간 정보를 확인할 수 있어요.")
                            .foregroundStyle(.gray)
                            .font(.system(size: ViewStyle.FontSize.smallSize))
                    }
                }
                .padding(.init(top: 15, leading: 0, bottom: 10, trailing: 0))
                
                if self.store.nowVicinityStationList.isEmpty {
                    ExpandedViewInSUI(alignment: .center) {
                        Text("현재 가까운 지하철역이 없어요.")
                            .font(.system(size: ViewStyle.FontSize.mediumSize, weight: .bold))
                            .padding(.vertical, 15)
                    }
                } else {
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal) {
                            HStack(spacing: 0) {
                                Color.clear
                                    .frame(width: 0, height: 0)
                                    .id("SCROLL_TO_TOP")
                                
                                LazyHStack(spacing: 0) {
                                    ForEach(Array(zip(self.store.state.nowVicinityStationList, self.store.state.nowVicinityStationList.indices)), id: \.1) { data, index in
                                        if self.store.state.nowTappedStationIndex  == nil {
                                            AnimationButtonInSUI(buttonView: {
                                                StationTitleViewInSUI(title: data.name, lineColor: data.lineColorName, size: 45, isFill: true, fontSize: ViewStyle.FontSize.smallSize)
                                            }) {
                                                self.store.send(.stationTapped(index))
                                            }
                                        } else if self.store.state.nowTappedStationIndex  != nil && self.store.state.nowTappedStationIndex  != index {
                                            AnimationButtonInSUI(buttonView: {
                                                VStack(spacing: 3) {
                                                    RoundedRectangle(cornerRadius: 3)
                                                        .fill(Color(data.lineColorName))
                                                        .frame(minWidth: 45)
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
                        }
                        .scrollIndicators(.hidden)
                        .padding(.bottom, self.store.nowTappedStationIndex == nil ? 10 : 0)
                        .animation(.smooth(duration: 0.3), value: self.store.state.nowTappedStationIndex)
                        
                        if let index = self.store.nowTappedStationIndex {
                            let tappedData = self.store.nowVicinityStationList[index]
                            
                            VStack(spacing: 0) {
                                VStack(spacing: 0) {
                                    HStack(spacing: 0) {
                                        VStack(alignment: .leading) {
                                            Spacer()
                                                .frame(height: 15)
                                            
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
                                                    let code = self.store.nowUpLiveData?.code ?? "99"
                                                    if code != "99" {
                                                        HStack {
                                                            if code == "0" || code == "1" || code == "2" {
                                                                Spacer()
                                                            }
                                                            Text(code == "" ? "" : FixInfo.saveSetting.detailVCTrainIcon)
                                                                .scaleEffect(x: -1, y: 1)
                                                                .padding(.bottom, 20)
                                                                .padding(.trailing, code == "0" ? 10 : 0)
                                                                .padding(.leading, code == "4" ? -15 : -5)
                                                            
                                                            if code == "4" || code == "5" {
                                                                Spacer()
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            let backStation = self.store.state.nowLiveDataLoading[0] ? "-" : self.store.nowUpLiveData?.backStationName ?? "-"
                                            Text(backStation.isEmpty ? "-" : backStation)
                                                .font(.system(size: ViewStyle.FontSize.smallSize))
                                            
                                            Spacer()
                                        }
                                        .offset(x: 10)
                                        
                                        StationTitleViewInSUI(title: tappedData.name, lineColor: tappedData.lineColorName,  size: 65, isFill: true, fontSize: ViewStyle.FontSize.smallSize)
                                        
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
                                                    let code = self.store.nowDownLiveData?.code ?? "99"
                                                    if code != "99" {
                                                        HStack {
                                                            if code == "4" || code == "5" {
                                                                Spacer()
                                                            }
                                                            
                                                            Text(code == "" ? "" : FixInfo.saveSetting.detailVCTrainIcon)
                                                                .padding(.bottom, 20)
                                                                .padding(.trailing, code == "4" ? -15 : -5)
                                                                .padding(.leading, code == "0" ? 10 : 0)
                                                            
                                                            if code == "0" || code == "1" || code == "2" {
                                                                Spacer()
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            let backStation = self.store.state.nowLiveDataLoading[1] ? "-" :
                                            self.store.nowDownLiveData?.backStationName ?? "-"
                                            Text(backStation.isEmpty ? "-" : backStation)
                                                .font(.system(size: ViewStyle.FontSize.smallSize))
                                        }
                                        .offset(x: -10, y: 5)
                                    }
                                    .animation(.smooth(duration: 0.4), value: self.store.state.nowTappedStationIndex)
                                    .padding(.top, 10)
                                    .padding(.bottom, 25)
                                    
                                    HStack {
                                        let upData = self.store.nowUpLiveData
                                        let downData = self.store.nowDownLiveData
                                        
                                        VStack(alignment: .leading, spacing: 5){
                                            Text(tappedData.line == "2호선" ? "외선" : "상행")
                                                .font(.system(size: ViewStyle.FontSize.smallSize))
                                            Text((upData == nil || self.store.nowLiveDataLoading[0]) ? "🔄 로딩 중"  : upData!.nowStateMSG.isEmpty ? "⚠️ 정보없음" : upData!.nowStateMSG)
                                                .font(.system(size: ViewStyle.FontSize.mediumSize, weight: .bold))
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 5){
                                            Text(tappedData.line == "2호선" ? "내선" : "하행")
                                                .font(.system(size: ViewStyle.FontSize.smallSize))
                                            Text((downData == nil || self.store.nowLiveDataLoading[1]) ?  "🔄 로딩 중"  : downData!.nowStateMSG.isEmpty ? "⚠️ 정보없음" : downData!.nowStateMSG)
                                                .font(.system(size: ViewStyle.FontSize.mediumSize, weight: .bold))
                                        }
                                    }
                                    .overlay {
                                        ExpandedViewInSUI(alignment: .center) {
                                            if self.store.nowUpLiveData != nil || self.store.nowDownLiveData == nil {
                                                RoundedRectangle(cornerRadius: 15)
                                                    .fill(Color(tappedData.lineColorName))
                                                    .frame(width: 1.5)
                                                    .frame(maxHeight: .infinity)
                                            }
                                        }
                                    }
                                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 15, trailing: 15))
                                }
                                .padding(.vertical, 15)
                                .padding(.horizontal, 7.5)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.gray.opacity(0.1))
                                )
                                .padding(.bottom, 15)
                                .clipped()
                                
                                ExpandedViewInSUI(alignment: .trailing) {
                                    HStack(spacing: 15) {
                                        Image(systemName: "arrow.up.to.line")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(.init(uiColor: .gray))
                                            .onTapGesture {
                                                self.store.send(.stationTapped(nil))
                                                proxy.scrollTo("SCROLL_TO_TOP", anchor: .top)
                                            }
                                        
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                            .resizable()
                                            .frame(width: 25, height: 20)
                                            .foregroundColor(.init(uiColor: .gray))
                                            .rotationEffect(.init(degrees: self.store.nowLiveDataLoading.filter {$0}.isEmpty ? 0 :180))
                                            .animation(.easeInOut(duration: 0.5), value: self.store.nowLiveDataLoading.map {$0}.isEmpty)
                                            .onTapGesture {
                                                self.store.send(.refreshBtnTapped)
                                            }
                                        
                                        Image(systemName: "arrow.up.left.and.arrow.down.right.circle")
                                            .resizable()
                                            .frame(width: 22, height: 22)
                                            .foregroundColor(.init(uiColor: .gray))
                                            .onTapGesture {
                                                self.store.send(.disposableDetailBtnTapped)
                                            }
                                    }
                                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                                }
                            }
                            .animation(.easeInOut(duration: 0.3), value: self.store.state.nowLiveDataLoading)
                            .padding(.bottom, 10)
                        } else {
                            AnimationButtonInSUI(
                                bgColor: Color("AppIconColor"), tappedBGColor: Color("AppIconColor"), buttonView: {
                                    Text("목록으로 확인하기")
                                        .foregroundStyle(.white)
                                        .font(.system(size: ViewStyle.FontSize.smallSize))
                                }) {
                                    self.store.send(.vicinityListOpenBtnTapped)
                                }
                                .frame(width: 200)
                                .padding(.bottom, 15)
                        }
                    }
                }
            }
            .padding(.horizontal, 15)
        }
    }
}

#Preview {
    SearchVicinityView(store: .constant(.init(initialState: .init(), reducer: {SearchFeature()})))
}
