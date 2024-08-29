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
            title: "\(self.store.sendedLoadModel.lineNumber.filter {$0 != "0"}) \(self.store.sendedLoadModel.stationName)",
            isLargeTitleHidden: true,
            backBtnTapped: {
                self.store.send(.backBtnTapped)
            }) {
                VStack(spacing: 20) {
                    HStack {
                        Text(self.store.backStationName ?? "")
                            .font(.system(size: ViewStyle.FontSize.smallSize, weight: .semibold))
                            .foregroundColor(.init(uiColor: .systemBackground))
                            .padding(.leading, 5)
                        
                        Spacer()
                        
                        Text(self.store.sendedLoadModel.stationName)
                            .font(.system(size: ViewStyle.FontSize.mediumSize, weight: .bold))
                            .background {
                                Circle()
                                    .stroke(Color.init(self.store.sendedLoadModel.lineNumber))
                                    .fill(Color.white)
                                    .frame(width: 75, height: 75)
                            }
                        
                        Spacer()
                        
                        Text(self.store.nextStationName ?? "")
                            .font(.system(size: ViewStyle.FontSize.smallSize, weight: .semibold))
                            .foregroundColor(.init(uiColor: .systemBackground))
                            .padding(.trailing, 5)
                    }
                    .frame(height: 50)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.init(self.store.sendedLoadModel.lineNumber))
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
                                let exception =  self.store.sendedLoadModel.exceptionLastStation.isEmpty ? "제외 행 없음" : self.store.sendedLoadModel.exceptionLastStation
                                Text(exception)
                                    .foregroundColor(.red)
                                    .font(.system(size: ViewStyle.FontSize.smallSize, weight: .medium))
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
                        stationInfo: self.store.sendedLoadModel
                    )
                }
                .padding(.top, 12.5)
            }
            .onAppear {
                self.store.send(.viewInitialized)
            }
    }
}
#Preview {
    DetailView(store: .init(initialState: .init(sendedLoadModel: DetailSendModel(upDown: "340", stationName: "상행", lineNumber: "", stationCode: "03호선", exceptionLastStation: "", korailCode: "")), reducer: {DetailFeature()}))
}
