//
//  DetailScheduleView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 8/29/24.
//

import SwiftUI

struct DetailScheduleView: View {
    private let gridItem = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
    var scheduleDataList: [ResultSchdule]
    let stationInfo: DetailSendModel
    var nowLoading: Bool
    let moreBtnTapped: () -> ()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("시간표")
                    .foregroundColor(.gray)
                    .font(.system(size: ViewStyle.FontSize.smallSize, weight: .semibold))
                Spacer()
            }
            .padding(.bottom, 15)
            
            MainStyleViewInSUI {
                VStack(spacing: 0) {
                    Button(action: {
                        self.moreBtnTapped()
                    },label: {
                        HStack {
                            let title = self.nowLoading ? "📡 시간표를 가져오고 있어요." :
                            FixInfo.saveSetting.detailScheduleAutoTime ?
                            (self.scheduleDataList.first == nil ? "⚠️ 시간표를 불러올 수 없어요." :
                                (self.scheduleDataList.first!.type == .Unowned ? "ℹ️ 시간표를 지원하지 않는 노선이에요." :
                                    (self.scheduleDataList.first!.startTime == "정보없음" ? "⚠️ 시간표를 불러올 수 없어요." :
                                        "\(self.scheduleDataList.first!.lastStation)행 \(self.scheduleDataList.first!.useArrTime)"
                                    )
                                )
                            ) : ""
                            Text("\(title)")
                                .font(.system(size: ViewStyle.FontSize.mediumSize, weight: .bold))
                            
                            Spacer()
                            
                            Image(systemName: "ellipsis")
                                .foregroundColor(.init(uiColor: .label))
                        }
                    })
                    .padding(.bottom, 20)
                    
                    ScrollView {
                        if self.nowLoading {
                            VStack {
                                Spacer()
                                ProgressView()
                                    .tint(Color("AppIconColor"))
                                Spacer()
                            }
                            .position(x: (UIScreen.main.bounds.width / 2) - 40, y: 100)
                        } else {
                            LazyVGrid(columns: self.gridItem) {
                                ForEach(self.scheduleDataList, id: \.startTime) { data in
                                    let isFast = data.isFast == "급행" ? "(급)" : ""
                                    let isInfoSuccess = data.startTime != "정보없음"
                                    let title = isInfoSuccess ? "⏱️ \(isFast)\(data.lastStation)행 \(data.useArrTime)" : "⚠️ 정보없음"
                                    
                                    HStack {
                                        Text(title)
                                            .font(.system(size: ViewStyle.FontSize.smallSize, weight: .medium))
                                            .foregroundColor(.white)
                                            .padding(.leading, 5)
                                        Spacer()
                                    }
                                    .frame(height: 40)
                                    .background {
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(isInfoSuccess ? Color("\(self.stationInfo.lineNumber)") : Color.init(uiColor: .gray))
                                    }
                                    .padding(EdgeInsets(top: 6, leading: 2.5, bottom: 6, trailing: 2.5))
                                }
                            }
                        }
                    }
                    .frame(height: 200)
                }
                .padding(15)
            }
        }
    }
}

#Preview {
    DetailScheduleView(scheduleDataList: [
            .init(startTime: "05:00:00", type: .Seoul, isFast: "", startStation: "수서", lastStation: "독립문"),
            .init(startTime: "05:09:00", type: .Seoul, isFast: "", startStation: "오금", lastStation: "구파발"),
            .init(startTime: "05:14:00", type: .Seoul, isFast: "", startStation: "오금", lastStation: "구파발"),
            .init(startTime: "05:17:00", type: .Seoul, isFast: "", startStation: "오금", lastStation: "대화"),
            .init(startTime: "05:24:00", type: .Seoul, isFast: "", startStation: "오금", lastStation: "구파발"),
            .init(startTime: "05:29:00", type: .Seoul, isFast: "", startStation: "오금", lastStation: "대화"),
            .init(startTime: "05:33:00", type: .Seoul, isFast: "", startStation: "수서", lastStation: "구파발"),
            .init(startTime: "05:40:00", type: .Seoul, isFast: "", startStation: "수서", lastStation: "대화"),
            .init(startTime: "05:46:00", type: .Seoul, isFast: "", startStation: "오금", lastStation: "구파발")
    ], stationInfo: .init(upDown: "상행", stationName: "340", lineNumber: "03호선", stationCode: "340", lineCode: "1003", exceptionLastStation: "", korailCode: ""), nowLoading: false){}
}
