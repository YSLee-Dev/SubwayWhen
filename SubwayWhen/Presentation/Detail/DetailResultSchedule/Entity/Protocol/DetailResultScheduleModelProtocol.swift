//
//  DetailResultScheduleModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/23.
//

import Foundation

protocol DetailResultScheduleModelProtocol{
    func resultScheduleToDetailResultSection(_ data : [ResultSchdule]) -> [DetailResultScheduleViewSectionData]
    func nowTimeMatching(_ data: [DetailResultScheduleViewSectionData], nowHour : Int) -> Int
}
