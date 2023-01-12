//
//  SearchInfoBySubwayNameService.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/12/05.
//

import Foundation

struct SearchSTNTimeTableByFRCodeService : Decodable {
    let row : [ScheduleStationArrival]
}
