//
//  RealtimeStationRowView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 4/11/26
//

import SwiftUI

struct RealtimeStationRowView: View {
    
    // MARK: - Properties
    
    let stationName: String
    let isSelected: Bool
    let isUp: Bool
    let position: RealtimeTrainPosition?
    let subwayLine: SubwayLineData
    let trainIcon: String
    
    private let circleSize: CGFloat = 15
    private let cellHeight: CGFloat = 60
    private let trainWidth: CGFloat = 85
    
    private var trainIconStatus: RealtimeTrainPosition.TrainIconStatus? {
        self.position?.trainIconStatus
    }
    
    private var trainIconAlignment: Alignment {
        switch self.trainIconStatus {
        case .departing: return self.isUp ?  .top : .bottom
        case .arriving: return .center
        case .passing: return self.isUp ? .bottom : .top
        case nil: return .center
        }
    }
    
    // MARK: - View
    
    var body: some View {
        HStack(spacing: 0) {
            if (self.position?.trainDirectionInfo.isEmpty ?? true) {
                Spacer()
                    .frame(width: self.trainWidth)
            } else {
                MainStyleViewInSUI {
                    Text(self.position?.trainDirectionInfo ?? "")
                        .font(.system(size: ViewStyle.FontSize.smallSize))
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(Color.secondary)
                        .minimumScaleFactor(0.5)
                        .padding(10)
                }
                .frame(width: self.trainWidth, alignment: .trailing)
            }
            
            Spacer()
                .frame(width: 10)
            
            self.trackView
            
            HStack(spacing: 0) {
                Text(self.stationName)
                    .font(
                        self.isSelected
                        ? .system(size: ViewStyle.FontSize.mediumSize, weight: .bold)
                        : .system(size: ViewStyle.FontSize.smallSize)
                    )
                    .padding(.leading, 10)
                    .foregroundStyle(self.isSelected ? Color.accentColor : Color.primary)
                
                Spacer()
                
                if self.isSelected {
                    Image(systemName: self.isUp ? "chevron.up" : "chevron.down")
                        .resizable()
                        .frame(width: 13, height: 8)
                        .foregroundStyle(.secondary)
                        .padding(.trailing, 10)
                }
            }
            .frame(height: self.cellHeight)
            .overlay {
                VStack(spacing: 0) {
                    Spacer()
                    
                    Rectangle()
                        .fill(Color(UIColor.separator))
                        .frame(height: 0.5)
                }
            }
        }
        .frame(height: self.cellHeight)
    }
}

// MARK: - Method

private extension RealtimeStationRowView {
    var trackView: some View {
        ZStack {
            Rectangle()
                .fill(Color(self.subwayLine.rawValue))
                .frame(width: 4.5)

            Circle()
                .stroke(Color(self.subwayLine.rawValue))
                .fill(Color.white)
                .frame(width: self.circleSize, height: self.circleSize)
        }
        .frame(width: 30)
        .frame(maxHeight: .infinity)
        .overlay(alignment: self.trainIconAlignment) {
            if self.trainIconStatus != nil {
                Text(self.trainIcon)
                    .font(.system(size: ViewStyle.FontSize.largeSize))
                    .overlay {
                        if let position = self.position,
                            position.isFast {
                            Text("💨")
                                .offset(x: 20, y: 0)
                                .font(.system(size: ViewStyle.FontSize.largeSize))
                                .rotationEffect(Angle(degrees: 90))
                        }
                    }
            }
        }
    }
}

#Preview {
    List {
        RealtimeStationRowView(stationName: "강남", isSelected: true, isUp: true, position: RealtimeTrainPosition(subwayId: "1002", subwayNm: "2호선", statnId: "1002000220", statnNm: "강남", trainNo: "2001", lastRecptnDt: "", recptnDt: "", updnLine: "0", statnTid: "1002000236", statnTnm: "신사", trainSttus: "1", directAt: "0", lstcarAt: "0"), subwayLine: .two, trainIcon: "🚇")
        RealtimeStationRowView(stationName: "역삼", isSelected: false, isUp: true, position: nil, subwayLine: .two, trainIcon: "🚇")
        RealtimeStationRowView(stationName: "선릉", isSelected: false, isUp: true, position: RealtimeTrainPosition(subwayId: "1002", subwayNm: "2호선", statnId: "1002000222", statnNm: "선릉", trainNo: "2002", lastRecptnDt: "", recptnDt: "", updnLine: "0", statnTid: "1002000236", statnTnm: "신사", trainSttus: "2", directAt: "0", lstcarAt: "0"), subwayLine: .two, trainIcon: "🚇")
        RealtimeStationRowView(stationName: "삼성", isSelected: false, isUp: true, position: nil, subwayLine: .two, trainIcon: "🚇")
    }
    .listStyle(.plain)
}
