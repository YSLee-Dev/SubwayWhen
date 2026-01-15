//
//  TestCongestionManager.swift
//  SubwayWhen
//
//  Created by 이윤수 on 1/15/26.
//

import Foundation

final class TestCongestionManager: CongestionManagerProtocol {
    
    var congestionDataSet: CongestionDataSet = congestionData
    var weakDay: Int = 2
    
    // MARK: - Methods
    
    func getAvailableStations() -> [String] {
        return self.congestionDataSet.stations
    }
    
    func getCongestions(station: String) -> [HourlyCongestionData]? {
        guard let dayData = self.getDayData(station) else {
            return nil
        }
        return dayData.map {HourlyCongestionData(hour: Int($0.key) ?? 0, congestion: $0.value)}.sorted {$0.hour < $1.hour}
    }
    
    func getCongestion(station: String, hour: Int) -> CongestionLevel? {
        return self.getDayData(station)?["\(hour)"]
    }
    
    func getLevel(station: String, hour: Int) -> Int? {
        return self.getCongestion(station: station, hour: hour)?.level
    }
    
    private func getDayData(_ station: String) -> [String: CongestionLevel]? {
        guard let stationData = self.congestionDataSet.stations[station]?.hourlyCongestion else {
            return nil
        }
        
        var dayData: [String: CongestionLevel]
        switch self.weakDay {
        case 1: dayData = stationData.sunday
        case 7: dayData = stationData.saturday
        default: dayData = stationData.weekday
        }
        
        for hour in 1...4 {
            if dayData["\(hour)"] == nil {
                dayData["\(hour)"] = CongestionLevel(percent: 0, level: 0)
            }
        }
        return dayData
    }
}
