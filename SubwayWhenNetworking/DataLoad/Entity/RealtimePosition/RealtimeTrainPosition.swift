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

    var subwayLineData: SubwayLineData {
        SubwayLineData(subwayId: subwayId)
    }

    var isUpward: Bool {
        self.updnLine == "0"
    }

    var isFast: Bool {
        self.directAt == "1" || self.directAt == "7"
    }
    
    var trainStatus: String {
        switch self.trainSttus {
        case "0": return "\(self.statnNm) 진입"
        case "1": return "\(self.statnNm) 도착"
        case "2": return "\(self.statnNm) 출발"
        case "3": return "전역 출발"
        default:  return "운행 중"
        }
    }
}
