//
//  CongestionDataSet.swift
//  SubwayWhen
//
//  Created by 이윤수 on 1/7/26.
//

import Foundation

struct CongestionDataSet: Decodable {
    let stations: [String: StationCongestion]
}
