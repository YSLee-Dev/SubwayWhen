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
            AppLogger.core.log(.error, "혼잡도 데이터를 로드하지 못함")
            return CongestionDataSet(stations: [:])
        }
        return decoded
    }
    
    private let holidayList: [String]

    // MARK: - Singleton

    private init() {
        self.holidayList = UserDefaults(suiteName: "group.com.yslee.subwaywhen")?.stringArray(forKey: "holidayList") ?? []
    }
    static let shared: CongestionManagerProtocol = CongestionManager()
    
    // MARK: - Methods
    
    func getAvailableStations() -> [String] {
        return self.congestionDataSet.stations.map {$0.key}.sorted {$0 < $1}
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
        
        var dayData: [String: CongestionLevel] = switch self.dayType() {
        case .holiday: stationData.sunday
        case .saturday: stationData.saturday
        case .weekday: stationData.weekday
        }
        
        if dayData.isEmpty {
            return dayData
        }
        
        for hour in 1...4 {
            if dayData["\(hour)"] == nil {
                dayData["\(hour)"] = CongestionLevel(percent: 0, level: 0)
            }
        }
        return dayData
    }
    
    private func dayType(date: Date = Date()) -> DayType {
        let weekday = Calendar.current.component(.weekday, from: date)
        if weekday == 1 { return .holiday }
        if weekday == 7 { return .saturday }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return self.holidayList.contains(formatter.string(from: date)) ? .holiday : .weekday
    }
}
