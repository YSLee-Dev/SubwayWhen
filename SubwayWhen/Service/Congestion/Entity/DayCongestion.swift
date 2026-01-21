//
//  DayCongestion.swift
//  SubwayWhen
//
//  Created by 이윤수 on 1/7/26.
//

import Foundation

struct DayCongestion: Decodable {
    let weekday: [String: CongestionLevel]
    let saturday: [String: CongestionLevel]
    let sunday: [String: CongestionLevel]
}
