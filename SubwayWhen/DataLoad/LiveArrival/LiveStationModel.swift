//
//  LiveStationModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/30.
//

import Foundation

struct LiveStationModel : Decodable{
    let realtimeArrivalList : [RealtimeStationArrival]
}
