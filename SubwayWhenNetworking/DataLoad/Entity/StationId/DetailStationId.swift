//
//  DetailStationId.swift
//  
//
//  Created by 이윤수 on 2023/01/04.
//

import Foundation

struct DetailStationId: Decodable, Equatable {
    let lineId : String
    let stationId : String
    let stationName : String
}
