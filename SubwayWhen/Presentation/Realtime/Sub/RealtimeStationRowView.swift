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
    let position: RealtimeTrainPosition?
    let subwayLine: SubwayLineData

    private let trackWidth: CGFloat = 28
    private let lineWidth: CGFloat = 4
    private let circleSize: CGFloat = 15

    private var trainIconStatus: RealtimeTrainPosition.TrainIconStatus? {
        self.position?.trainIconStatus
    }

    // MARK: - View

    var body: some View {
        HStack(spacing: 0) {
            Text(self.position?.trainDirectionInfo ?? "")
                .font(.system(size: ViewStyle.FontSize.smallSize))
                .foregroundStyle(Color.secondary)
                .frame(width: 70, alignment: .trailing)
                .padding(.vertical, ViewStyle.padding.mainStyleViewTB)

            Spacer().frame(width: 8)

            self.trackView

            Spacer().frame(width: 8)

            Text(self.stationName)
                .font(
                    self.isSelected
                    ? .system(size: ViewStyle.FontSize.mediumSize, weight: .bold)
                    : .system(size: ViewStyle.FontSize.mediumSize)
                )
                .foregroundStyle(self.isSelected ? Color.accentColor : Color.primary)
                .padding(.vertical, ViewStyle.padding.mainStyleViewTB)

            Spacer()
        }
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .padding(.horizontal, ViewStyle.padding.mainStyleViewLR)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(UIColor.separator))
                .frame(height: 0.5)
        }
    }
}

// MARK: - Method

private extension RealtimeStationRowView {
    var trackView: some View {
        ZStack {
            Rectangle()
                .fill(Color(self.subwayLine.rawValue))
                .frame(width: self.lineWidth)

            Circle()
                .stroke(Color(self.subwayLine.rawValue))
                .fill(Color.white)
                .frame(width: self.circleSize, height: self.circleSize)
        }
        .frame(width: self.trackWidth)
        .frame(maxHeight: .infinity)
        .overlay(alignment: self.trainIconAlignment) {
            if self.trainIconStatus != nil {
                Text(FixInfo.saveSetting.detailVCTrainIcon)
                    .font(.system(size: ViewStyle.FontSize.largeSize))
            }
        }
    }

    var trainIconAlignment: Alignment {
        switch self.trainIconStatus {
        case .departing: return .top
        case .arriving:  return .center
        case .passing:   return .bottom
        case nil:        return .center
        }
    }
}

#Preview {
    List {
        RealtimeStationRowView(stationName: "강남", isSelected: true, position: RealtimeTrainPosition(subwayId: "1002", subwayNm: "2호선", statnId: "1002000220", statnNm: "강남", trainNo: "2001", lastRecptnDt: "", recptnDt: "", updnLine: "0", statnTid: "1002000236", statnTnm: "신사", trainSttus: "1", directAt: "0", lstcarAt: "0"), subwayLine: .two)
        RealtimeStationRowView(stationName: "역삼", isSelected: false, position: nil, subwayLine: .two)
        RealtimeStationRowView(stationName: "선릉", isSelected: false, position: RealtimeTrainPosition(subwayId: "1002", subwayNm: "2호선", statnId: "1002000222", statnNm: "선릉", trainNo: "2002", lastRecptnDt: "", recptnDt: "", updnLine: "0", statnTid: "1002000236", statnTnm: "신사", trainSttus: "2", directAt: "0", lstcarAt: "0"), subwayLine: .two)
        RealtimeStationRowView(stationName: "삼성", isSelected: false, position: nil, subwayLine: .two)
    }
    .listStyle(.plain)
}
