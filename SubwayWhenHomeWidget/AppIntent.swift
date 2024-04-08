//
//  AppIntent.swift
//  SubwayWhenHomeWidget
//
//  Created by 이윤수 on 3/28/24.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "위젯에서 보고 싶은 지하철역을 골라주세요."
    
    @Parameter(title: "지하철역 선택", optionsProvider: SaveStationProvider())
    var seletedStation: String?
    
    @Parameter(title: "현재 시각 시간표 포함", default: true)
    var nowTimeScheduleIsInsert: Bool
    
    struct SaveStationProvider: DynamicOptionsProvider {
        var saveStation: [String] {
            guard let data = UserDefaults.shared.data(forKey: "saveStation") ,
                  let list = try? PropertyListDecoder().decode([SaveStation].self, from: data)
            else {return []}
            
            return list.filter{$0.allowScheduleLoad}.map {$0.widgetUseText}
        }
        typealias Result = [String]
        
        func results() async throws -> Result {
            saveStation
        }
        
        func defaultResult() async -> String? {
            saveStation.first
        }
    }
}

