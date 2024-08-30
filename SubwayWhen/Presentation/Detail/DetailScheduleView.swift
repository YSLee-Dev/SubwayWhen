//
//  DetailScheduleView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 8/29/24.
//

import SwiftUI

struct DetailScheduleView: View {
    private let gridItem = [GridItem(.flexible()), GridItem(.flexible())]
    var scheduleDataList: [ResultSchdule]
    let stationInfo: DetailSendModel
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
                    HStack {
                        let title = FixInfo.saveSetting.detailAutoReload ? 
                        (self.scheduleDataList.first == nil ? "시간표를 불러올 수 없어요." :
                            (self.scheduleDataList.first!.type == .Unowned ? "시간표를 지원하지 않는 노선이에요." :
                                (self.scheduleDataList.first!.useArrTime == "정보없음" ? "시간표를 불러올 수 없어요" :
                                    "\(self.scheduleDataList.first!.lastStation)행 \(self.scheduleDataList.first!.useArrTime)"
                                )
                            )
                        ) : ""
                        Text("\(title)")
                            .font(.system(size: ViewStyle.FontSize.mediumSize, weight: .bold))
                        
                        Spacer()
                        
                        Button(action: {
                            self.moreBtnTapped()
                        }, label: {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.init(uiColor: .label))
                        })
                    }
                    .padding(.bottom, 10)
                    
                    ScrollView {
                        LazyVGrid(columns: self.gridItem) {
                            ForEach(self.scheduleDataList, id: \.startTime) { data in
                                HStack {
                                    let isFast = data.isFast == "급행" ? "(급)" : ""
                                    let title = data.startTime == "⚠️ 정보없음" ? "" : "⏱️ \(isFast)\(data.lastStation)행 \(data.useArrTime)"
                                    Text(title)
                                        .font(.system(size: ViewStyle.FontSize.smallSize, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.leading, 5)
                                    Spacer()
                                }
                                .frame(height: 37.5)
                                .background {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color("\(self.stationInfo.lineNumber)"))
                                }
                                .padding(5)
                            }
                        }
                    }
                    .frame(height: 150)
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
    ], stationInfo: .init(upDown: "상행", stationName: "340", lineNumber: "03호선", stationCode: "340", lineCode: "1003", exceptionLastStation: "", korailCode: "")){}
}
