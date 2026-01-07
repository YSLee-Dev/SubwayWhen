//
//  StationCongestion.swift
//  SubwayWhen
//
//  Created by 이윤수 on 1/7/26.
//

import Foundation

struct StationCongestion: Decodable {
    let hourlyCongestion: [String: CongestionLevel]
    
    enum CodingKeys: String, CodingKey {
        case hourlyCongestion = "hourly_congestion"
    }
}
