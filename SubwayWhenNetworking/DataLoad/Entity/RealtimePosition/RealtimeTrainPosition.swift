//
//  RealtimeTrainPosition.swift
//  SubwayWhenNetworking
//
//  Created by 이윤수 on 2026/04/05.
//

import Foundation

struct RealtimeTrainPosition: Decodable, Equatable, Hashable {
    let subwayId: String
    let subwayNm: String
    let statnId: String
    let statnNm: String
    let trainNo: String
    let lastRecptnDt: String
    let recptnDt: String
    let updnLine: String
    let statnTid: String
    let statnTnm: String
    let trainSttus: String
    let directAt: String
    let lstcarAt: String
    
    enum TrainIconStatus {
        case arriving
        case departing
        case passing
    }

    var isFast: Bool {
        self.directAt == "1" || self.directAt == "7"
    }

    var trainDirectionInfo: String {
        let statusText: String
        switch self.trainSttus {
        case "0": statusText = "진입"
        case "1": statusText = "도착"
        case "2": statusText = "출발"
        default:  statusText = "운행중"
        }
        return "\(self.statnTnm)행\n\(statusText)"
    }

    var trainIconStatus: TrainIconStatus {
        switch self.trainSttus {
        case "1": return .arriving
        case "2": return .departing
        default:  return .passing
        }
    }
}
