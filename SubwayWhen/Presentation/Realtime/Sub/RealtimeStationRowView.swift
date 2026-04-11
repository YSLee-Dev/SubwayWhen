//
//  RealtimeStationRowView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 4/11/26
//

import SwiftUI

enum TrainIconStatus {
    case arriving
    case departing
    case passing
}

struct RealtimeStationRowView: View {

    // MARK: - Properties

    let stationName: String
    let isSelected: Bool
    let position: RealtimeTrainPosition?
    let subwayLine: SubwayLineData

    private let trackWidth: CGFloat = 28
    private let lineWidth: CGFloat = 4
    private let circleSize: CGFloat = 15
    
    private var trainInfo: String {
        guard let position else { return "" }
        let statusText: String
        switch position.trainSttus {
        case "0": statusText = Strings.Realtime.trainStatusEntering
        case "1": statusText = Strings.Realtime.trainStatusArrived
        case "2": statusText = Strings.Realtime.trainStatusDeparted
        default:  statusText = Strings.Realtime.trainStatusRunning
        }
        return "\(position.statnTnm)\(Strings.Realtime.directionSuffix) \(statusText)"
    }

    private var trainStatus: TrainIconStatus? {
        guard let position else { return nil }
        switch position.trainSttus {
        case "2": return .departing
        case "1": return .arriving
        default:  return .passing
        }
    }

    // MARK: - View

    var body: some View {
        HStack(spacing: 0) {
            Text(trainInfo)
                .font(.system(size: ViewStyle.FontSize.smallSize))
                .foregroundStyle(Color.secondary)
                .frame(width: 70, alignment: .trailing)
                .padding(.vertical, ViewStyle.padding.mainStyleViewTB)

            Spacer().frame(width: 8)

            trackView

            Spacer().frame(width: 8)

            Text(stationName)
                .font(
                    isSelected
                    ? .system(size: ViewStyle.FontSize.mediumSize, weight: .bold)
                    : .system(size: ViewStyle.FontSize.mediumSize)
                )
                .foregroundStyle(isSelected ? Color.accentColor : Color.primary)
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
                .fill(Color(subwayLine.rawValue))
                .frame(width: lineWidth)

            Circle()
                .stroke(Color(subwayLine.rawValue))
                .fill(Color.white)
                .frame(width: circleSize, height: circleSize)
        }
        .frame(width: trackWidth)
        .frame(maxHeight: .infinity)
        .overlay(alignment: trainIconAlignment) {
            if trainStatus != nil {
                Text(FixInfo.saveSetting.detailVCTrainIcon)
                    .font(.system(size: ViewStyle.FontSize.largeSize))
            }
        }
    }

    var trainIconAlignment: Alignment {
        switch trainStatus {
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
