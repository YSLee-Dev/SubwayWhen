//
//  CongestionManager.swift
//  SubwayWhen
//
//  Created by 이윤수 on 1/7/26.
//

import Foundation

final class CongestionManager: CongestionManagerProtocol {
    
    // MARK: - Properties
    
    private var congestionDataSet: CongestionDataSet {
        guard let url = Bundle.main.url(forResource: "CongestionData", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(CongestionDataSet.self, from: data) else {
            print("혼잡도 데이터를 로드하지 못함")
            return CongestionDataSet(stations: [:])
        }
        return decoded
    }
    
    // MARK: - Singleton
    
    private init() {}
    static let shared: CongestionManagerProtocol = CongestionManager()
    
    // MARK: - Methods
    
    func getAvailableStations() -> [String] {
        return self.congestionDataSet.stations.map {$0.key}.sorted {$0 < $1}
    }
    
    func getCongestion(station: String, hour: Int) -> CongestionLevel? {
        guard let stationData = self.congestionDataSet.stations[station]?.hourlyCongestion else {
            return nil
        }
        
        let dayData: [String: CongestionLevel]
        switch self.getCurrentWeekday() {
        case "weekday": dayData = stationData.weekday
        case "saturday": dayData = stationData.saturday
        default: dayData = stationData.sunday
        }
        return dayData["\(hour)"]
    }
    
    func getLevel(station: String, hour: Int) -> Int? {
        self.getCongestion(station: station, hour: hour)?.level
    }
    
    private func getCurrentWeekday() -> String {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return switch weekday {
        case 1: "sunday"
        case 7: "saturday"
        default: "weekday"
        }
    }
}
