//
//  DetailView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 8/26/24.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct DetailView: View {
    @State private var store: StoreOf<DetailFeature>
    
    init(store: StoreOf<DetailFeature>) {
        self.store = store
    }
    
    var body: some View {
        NavigationBarScrollViewInSUI(
            title: "\(self.store.isDisposable ? "(저장안됨)" : "") \(self.store.sendedLoadModel.lineNumber.filter {$0 != "0"}) \(self.store.sendedLoadModel.stationName)",
            isLargeTitleHidden: true,
            backBtnTapped: {
                self.store.send(.backBtnTapped)
            }, backBtnIcon: self.store.isDisposable ? "arrow.down" : "arrow.left") {
                VStack(spacing: 20) {
                    HStack {
                        Text(self.store.backStationName ?? "")
                            .font(.system(size: ViewStyle.FontSize.smallSize, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                        
                        Spacer()
                        
                        Text(self.store.nextStationName ?? "")
                            .font(.system(size: ViewStyle.FontSize.smallSize, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.trailing, 10)
                    }
                    .frame(width: UIScreen.main.bounds.width - 40 ,height: 50)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.init(self.store.sendedLoadModel.lineNumber))
                    }
                    .overlay {
                        HStack {
                            Spacer()
                            StationTitleViewInSUI(
                                title: self.store.sendedLoadModel.stationName,
                                lineColor: self.store.sendedLoadModel.lineNumber,
                                size: 75,
                                isFill: false
                            )
                            Spacer()
                        }
                    }
                    
                    HStack(spacing: 20) {
                        MainStyleViewInSUI {
                            Text(self.store.sendedLoadModel.upDown)
                                .foregroundColor(Color.init(uiColor: .label))
                                .font(.system(size: ViewStyle.FontSize.smallSize, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                        }
                        
                        MainStyleViewInSUI {
                            Button(action: {
                                self.store.send(.exceptionLastStationBtnTapped)
                            }) {
                                let exception =  self.store.sendedLoadModel.exceptionLastStation.isEmpty ? "제외 행 없음" : "\( self.store.sendedLoadModel.exceptionLastStation)행 제외"
                                HStack {
                                    Text(exception)
                                        .foregroundColor(.red)
                                        .font(.system(size: ViewStyle.FontSize.smallSize, weight: .medium))
                                    
                                    if !self.store.sendedLoadModel.exceptionLastStation.isEmpty {
                                        Image(systemName: "arrowtriangle.down")
                                            .resizable()
                                            .frame(width: 10, height: 10)
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                        }
                    }
                    
                    DetailArrivalView(
                        arrivalDataList: self.store.nowArrivalData, stationInfo: self.store.sendedLoadModel, backStationName: self.store.backStationName ?? "", nowLoading: self.store.nowArrivalLoading, nowSeconds: self.store.nowTimer) {
                            self.store.send(.refreshBtnTapped)
                        }
                    
                    DetailScheduleView(
                        scheduleDataList: self.store.nowSculeduleSortedData,
                        stationInfo: self.store.sendedLoadModel,
                        nowLoading: self.store.nowScheduleLoading,
                        isDisposable: self.store.isDisposable
                    ) {
                        self.store.send(.scheduleMoreBtnTapped)
                    }
                    
                    if let lineBarnd = ReportBrandData(rawValue: self.store.sendedLoadModel.lineNumber) {
                        VStack(spacing: 0) {
                            HStack {
                                Text("기타")
                                    .foregroundColor(.gray)
                                    .font(.system(size: ViewStyle.FontSize.smallSize, weight: .semibold))
                                Spacer()
                            }
                            .padding(.bottom, 15)
                            
                            MainStyleViewInSUI {
                                Button(action: {
                                    self.store.send(.reportBtnTapped(lineBarnd))
                                }) {
                                    Text("\(self.store.sendedLoadModel.lineNumber.filter{$0 != "0"}) 민원접수")
                                        .foregroundColor(.red)
                                        .font(.system(size: ViewStyle.FontSize.smallSize, weight: .medium))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                }
                            }
                        }
                    }
                }
                .padding(.top, 12.5)
            }
            .padding(.top, self.store.isDisposable ? 15 : 0)
            .confirmationDialog(self.$store.scope(state: \.dialogState, action: \.dialogAction))
            .onAppear {
                self.store.send(.viewInitialized)
            }
            .onDisappear {
                self.store.send(.viewDisappear)
            }
    }
}
#Preview {
    DetailView(store: .init(initialState: .init(isDisposable: true, sendedLoadModel: DetailSendModel(upDown: "상행", stationName: "양재", lineNumber: "03호선", stationCode: "340", lineCode: "1003", exceptionLastStation: "구파발", korailCode: "")), reducer: {DetailFeature()}))
}
