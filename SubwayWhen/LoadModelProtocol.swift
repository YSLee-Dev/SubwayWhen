//
//  StationArrivalLoadProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/01.
//

import Foundation

protocol StationArrivalLoadProtocol : AnyObject{
    var realtimeArrivalList : [RealtimeStationArrival] {get set}
}
