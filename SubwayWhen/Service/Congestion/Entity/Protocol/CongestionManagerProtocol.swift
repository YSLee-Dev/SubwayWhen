//
//  CongestionManagerProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 1/7/26.
//

import Foundation

protocol CongestionManagerProtocol {
    /// 혼잡도 레벨을 지원하는 역을 가져올 때 사용해요.
    func getAvailableStations() -> [String]
    /// 특정 역의 특정 시간의 혼잡도 전체 레벨을 가져올 때 사용해요.
    func getCongestion(station: String, hour: Int) -> CongestionLevel?
    /// 특정 역의 특정 시간의 혼잡도 이모지 레벨을 가져올 때 사용해요.
    func getLevel(station: String, hour: Int) -> Int?
}
