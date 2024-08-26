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
            title: "\(self.store.sendedScheduleModel.line.filter {$0 != "0"}) \(self.store.sendedStationName)",
            isLargeTitleHidden: true,
            backBtnTapped: {
                self.store.send(.backBtnTapped)
            }) {
                VStack {
                    HStack {
                        Text(self.store.backStationName ?? "")
                            .font(.system(size: ViewStyle.FontSize.smallSize, weight: .semibold))
                            .foregroundColor(.init(uiColor: .systemBackground))
                            .padding(.leading, 5)
                        
                        Spacer()
                        
                        Text(self.store.sendedStationName)
                            .font(.system(size: ViewStyle.FontSize.mediumSize, weight: .bold))
                            .background {
                                Circle()
                                    .stroke(Color.init(self.store.sendedScheduleModel.line))
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
                            .fill(Color.init(self.store.sendedScheduleModel.line))
                    }
                    
                    HStack(spacing: 20) {
                        MainStyleViewInSUI {
                            Text(self.store.sendedScheduleModel.upDown)
                                .foregroundColor(Color.init(uiColor: .label))
                                .font(.system(size: ViewStyle.FontSize.smallSize, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                        }
                        
                        MainStyleViewInSUI {
                            Button(action: {
                                self.store.send(.exceptionLastStationBtnTapped)
                            }) {
                                let exception =  self.store.sendedScheduleModel.exceptionLastStation.isEmpty ? "제외 행 없음" : self.store.sendedScheduleModel.exceptionLastStation
                                Text(exception)
                                    .foregroundColor(.red)
                                    .font(.system(size: ViewStyle.FontSize.smallSize, weight: .medium))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                        }
                    }
                    .padding(.top, 15)
                }
                .padding(.top, 12.5)
            }
            .onAppear {
                self.store.send(.viewInitialized)
            }
    }
}

#Preview {
    DetailView(store: .init(initialState: .init(sendedStationName: "교대", sendedScheduleModel: ScheduleSearch(stationCode: "340", upDown: "상행", exceptionLastStation: "", line: "03호선", korailCode: "")), reducer: {DetailFeature()}))
}
